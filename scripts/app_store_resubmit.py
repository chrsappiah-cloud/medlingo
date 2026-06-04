#!/usr/bin/env python3
"""Upload listing screenshots and submit Medlingo for App Review via reviewSubmissions API."""

from __future__ import annotations

import json
import os
import subprocess
import sys
import tempfile
import time
import urllib.error
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))
from app_store_submit import ASCClient, API_V1, attach_build, upload_ipa

CONFIG = json.loads((ROOT / "config/app_store_connect.json").read_text())
APP_ID = CONFIG["appId"]
DEFAULT_ISSUER = CONFIG["issuerId"]
DEFAULT_KEY_ID = CONFIG["keyId"]
VERSION_ID = CONFIG["versionId"]
BUILD_NUMBER = os.environ.get("BUILD_NUMBER", CONFIG.get("buildNumber", ""))
LOCALIZATION_ID = "e3f09bbf-0a42-4e37-8511-77e47903dae5"
IPHONE_DIR = ROOT / "distribution/screenshots/6.7-inch"
IPAD_DIR = ROOT / "distribution/screenshots/13-inch-iPad"
REVIEW_REPLY = ROOT / "distribution/AppStoreReviewReply-Jun05-2026.txt"
SCREENSHOT_FILENAMES = [
    "01-learn-home.png",
    "02-practice-lab.png",
    "03-anatomy-labeling.png",
    "04-collection-gallery.png",
    "05-progress-dashboard.png",
    "06-tutor-sessions.png",
]

SCREENSHOT_TYPES = [
    ("APP_IPHONE_67", IPHONE_DIR, (1290, 2796)),
    ("APP_IPAD_PRO_3GEN_129", IPAD_DIR, (2048, 2732)),
]


def resolve_build_id(client: ASCClient, build_number: str) -> str:
    builds = client.get(
        f"{API_V1}/builds?filter[app]={APP_ID}&limit=50"
    )
    for item in builds.get("data", []):
        if item["attributes"].get("version") == build_number:
            return item["id"]
    raise RuntimeError(f"Build {build_number} not found in App Store Connect yet")


def wait_for_build(client: ASCClient, build_number: str, timeout_s: int = 900) -> str:
    deadline = time.time() + timeout_s
    while time.time() < deadline:
        try:
            return resolve_build_id(client, build_number)
        except RuntimeError:
            print(f"  waiting for build {build_number} to appear in Connect…")
            time.sleep(30)
    raise TimeoutError(f"Build {build_number} not available after {timeout_s}s")


def resize_screenshot(src: Path, dest: Path, width: int, height: int) -> None:
    dest.parent.mkdir(parents=True, exist_ok=True)
    subprocess.run(
        ["sips", "-z", str(height), str(width), str(src), "--out", str(dest)],
        check=True,
        capture_output=True,
    )


def screenshot_has_size(src: Path, width: int, height: int) -> bool:
    result = subprocess.run(
        ["sips", "-g", "pixelWidth", "-g", "pixelHeight", str(src)],
        check=True,
        capture_output=True,
        text=True,
    )
    return f"pixelWidth: {width}" in result.stdout and f"pixelHeight: {height}" in result.stdout


def ordered_screenshots(source_dir: Path) -> list[Path]:
    sources = [source_dir / filename for filename in SCREENSHOT_FILENAMES]
    missing = [str(path) for path in sources if not path.exists()]
    if missing:
        raise FileNotFoundError(
            "Missing required App Store screenshots:\n" + "\n".join(missing)
        )
    return sources


def delete_existing_screenshot_set(client: ASCClient, display_type: str) -> None:
    existing = client.get(
        f"{API_V1}/appStoreVersionLocalizations/{LOCALIZATION_ID}/appScreenshotSets?limit=50"
    )
    for item in existing.get("data", []):
        if item.get("attributes", {}).get("screenshotDisplayType") != display_type:
            continue
        set_id = item["id"]
        status, resp = client.delete(f"{API_V1}/appScreenshotSets/{set_id}")
        if status not in (200, 204):
            raise RuntimeError(f"Delete screenshot set {display_type} failed: {resp}")
        print(f"  deleted existing {display_type} set {set_id}")


def upload_listing_screenshots(client: ASCClient) -> None:
    print("→ Uploading App Store listing screenshots (iPhone 6.7\" + iPad 13\")…")

    with tempfile.TemporaryDirectory() as tmp:
        tmp_path = Path(tmp)
        for display_type, source_dir, (w, h) in SCREENSHOT_TYPES:
            sources = ordered_screenshots(source_dir)
            delete_existing_screenshot_set(client, display_type)

            status, resp = client.post(
                f"{API_V1}/appScreenshotSets",
                {
                    "data": {
                        "type": "appScreenshotSets",
                        "attributes": {"screenshotDisplayType": display_type},
                        "relationships": {
                            "appStoreVersionLocalization": {
                                "data": {
                                    "type": "appStoreVersionLocalizations",
                                    "id": LOCALIZATION_ID,
                                }
                            }
                        },
                    }
                },
            )
            if status not in (200, 201):
                raise RuntimeError(f"Create screenshot set {display_type} failed: {resp}")
            set_id = resp["data"]["id"]
            print(f"  set {display_type}: {set_id}")

            for idx, src in enumerate(sources, start=1):
                img = src
                if not screenshot_has_size(src, w, h):
                    img = tmp_path / f"{display_type.lower()}_{idx:02d}_{src.name}"
                    resize_screenshot(src, img, w, h)

                status, resp = client.post(
                    f"{API_V1}/appScreenshots",
                    {
                        "data": {
                            "type": "appScreenshots",
                            "attributes": {
                                "fileName": img.name,
                                "fileSize": img.stat().st_size,
                            },
                            "relationships": {
                                "appScreenshotSet": {
                                    "data": {"type": "appScreenshotSets", "id": set_id}
                                }
                            },
                        }
                    },
                )
                if status not in (200, 201):
                    raise RuntimeError(f"appScreenshots reserve failed: {resp}")

                shot_id = resp["data"]["id"]
                ops = resp["data"]["attributes"].get("uploadOperations", [])
                if not ops:
                    raise RuntimeError(f"No upload ops: {resp}")

                client.upload_binary(ops[0], img)
                status, resp = client.patch(
                    f"{API_V1}/appScreenshots/{shot_id}",
                    {
                        "data": {
                            "type": "appScreenshots",
                            "id": shot_id,
                            "attributes": {"uploaded": True},
                        }
                    },
                )
                if status not in (200, 201):
                    raise RuntimeError(f"appScreenshots commit failed: {resp}")
            print(f"  ✓ uploaded {len(sources)} screenshots for {display_type}")


def update_review_notes(client: ASCClient) -> None:
    notes_path = REVIEW_REPLY if REVIEW_REPLY.exists() else ROOT / "docs/AppStoreResolutionCenterReply-2.1b.txt"
    review_notes = notes_path.read_text()
    detail = client.get(f"{API_V1}/appStoreVersions/{VERSION_ID}/appStoreReviewDetail")
    detail_id = detail["data"]["id"]
    status, resp = client.patch(
        f"{API_V1}/appStoreReviewDetails/{detail_id}",
        {
            "data": {
                "type": "appStoreReviewDetails",
                "id": detail_id,
                "attributes": {"notes": review_notes[:4000]},
            }
        },
    )
    if status not in (200, 201):
        raise RuntimeError(f"Review notes failed: {resp}")
    print("✓ App Review notes updated")


def cancel_blocking_submissions(client: ASCClient) -> None:
    """Cancel UNRESOLVED review submissions that lock the app version."""
    subs = client.get(f"{API_V1}/apps/{APP_ID}/reviewSubmissions")
    for sub in subs.get("data", []):
        state = sub["attributes"]["state"]
        if state in ("UNRESOLVED_ISSUES", "READY_FOR_REVIEW"):
            sid = sub["id"]
            status, _ = client.patch(
                f"{API_V1}/reviewSubmissions/{sid}",
                {
                    "data": {
                        "type": "reviewSubmissions",
                        "id": sid,
                        "attributes": {"canceled": True},
                    }
                },
            )
            if status in (200, 201):
                print(f"  canceled prior submission {sid} ({state})")


def submit_for_review(client: ASCClient) -> str:
    print("→ Preparing review submission…")
    cancel_blocking_submissions(client)

    status, resp = client.post(
        f"{API_V1}/reviewSubmissions",
        {
            "data": {
                "type": "reviewSubmissions",
                "relationships": {
                    "app": {"data": {"type": "apps", "id": APP_ID}},
                },
            }
        },
    )
    if status not in (200, 201):
        raise RuntimeError(f"Create review submission failed: {resp}")
    submission_id = resp["data"]["id"]
    print(f"  submission id: {submission_id}")

    status, _ = client.patch(
        f"{API_V1}/reviewSubmissions/{submission_id}",
        {
            "data": {
                "type": "reviewSubmissions",
                "id": submission_id,
                "attributes": {"platform": "IOS"},
            }
        },
    )
    if status not in (200, 201):
        raise RuntimeError("Failed to set review submission platform")

    status, resp = client.post(
        f"{API_V1}/reviewSubmissionItems",
        {
            "data": {
                "type": "reviewSubmissionItems",
                "relationships": {
                    "reviewSubmission": {
                        "data": {"type": "reviewSubmissions", "id": submission_id}
                    },
                    "appStoreVersion": {
                        "data": {"type": "appStoreVersions", "id": VERSION_ID}
                    },
                },
            }
        },
    )
    if status not in (200, 201):
        raise RuntimeError(f"Add app version failed: {resp}")
    print("  app version added")

    status, resp = client.patch(
        f"{API_V1}/reviewSubmissions/{submission_id}",
        {
            "data": {
                "type": "reviewSubmissions",
                "id": submission_id,
                "attributes": {"submitted": True},
            }
        },
    )
    if status not in (200, 201):
        raise RuntimeError(f"Submit failed: {resp}")

    final = client.get(f"{API_V1}/reviewSubmissions/{submission_id}")
    state = final["data"]["attributes"]["state"]
    print(f"✓ Review submission state: {state}")
    return submission_id


def package_ipa_fallback(archive_path: Path, export_dir: Path, build_number: str) -> Path:
    """Manual IPA packaging when xcodebuild -exportArchive rsync step fails (exit 70).

    Copies the .app from the archive, embeds the App Store provisioning profile,
    re-signs with the Apple Distribution certificate, and zips into an IPA.
    This reproduces what xcodebuild -exportArchive does without the content-delivery step.
    """
    app_src = archive_path / "Products/Applications/medlingo.app"
    if not app_src.exists():
        raise FileNotFoundError(f"No .app in archive: {app_src}")

    profiles_dir = Path.home() / "Library/Developer/Xcode/UserData/Provisioning Profiles"
    dist_profile = _find_appstore_profile(profiles_dir, CONFIG["bundleId"])
    if not dist_profile:
        raise RuntimeError("No App Store provisioning profile found for wcs.medlingo")

    staging = export_dir / "_ipa_staging"
    payload = staging / "Payload"
    payload.mkdir(parents=True, exist_ok=True)
    app_dest = payload / "medlingo.app"

    subprocess.run(["cp", "-R", str(app_src), str(app_dest)], check=True)
    subprocess.run(["cp", str(dist_profile), str(app_dest / "embedded.mobileprovision")], check=True)

    entitlements = ROOT / "build/ExportEntitlements.plist"
    codesign_cmd = [
        "codesign", "--force", "--sign",
        "Apple Distribution: Christopher Appiah-Thompson (TM2WG7HH96)",
        str(app_dest),
    ]
    if entitlements.exists():
        codesign_cmd += ["--entitlements", str(entitlements)]
    subprocess.run(codesign_cmd, check=True)

    ipa_path = export_dir / "medlingo.ipa"
    subprocess.run(
        ["zip", "-r", str(ipa_path), "Payload/", "-x", "*.DS_Store"],
        cwd=str(staging), check=True, capture_output=True,
    )
    print(f"  IPA packaged (fallback): {ipa_path} ({ipa_path.stat().st_size // 1024 // 1024}MB)")
    return ipa_path


def _find_appstore_profile(profiles_dir: Path, bundle_id: str) -> Path | None:
    import plistlib
    for f in profiles_dir.glob("*.mobileprovision"):
        try:
            result = subprocess.run(
                ["security", "cms", "-D", "-i", str(f)],
                capture_output=True, check=True,
            )
            plist = plistlib.loads(result.stdout)
            entitlement_id = plist.get("Entitlements", {}).get("application-identifier", "")
            has_devices = bool(plist.get("ProvisionedDevices"))
            provisions_all = plist.get("ProvisionsAllDevices", False)
            is_appstore = not has_devices and not provisions_all
            if is_appstore and bundle_id in entitlement_id:
                return f
        except Exception:
            continue
    return None


def build_and_package_ipa(build_number: str) -> Path:
    """Archive, attempt export, fall back to manual packaging on rsync failure (exit 70)."""
    archive_path = ROOT / f"build/medlingo-{build_number}.xcarchive"
    export_dir = ROOT / f"build/export-{build_number}"
    export_dir.mkdir(parents=True, exist_ok=True)
    export_opts = ROOT / "build/ExportOptions.plist"

    if not archive_path.exists():
        print(f"→ Archiving build {build_number}…")
        subprocess.run([
            "xcodebuild", "archive",
            "-project", str(ROOT / "medlingo.xcodeproj"),
            "-scheme", "medlingo",
            "-configuration", "Release",
            "-archivePath", str(archive_path),
            f"CURRENT_PROJECT_VERSION={build_number}",
        ], check=True, capture_output=True)
        print("  ✓ Archive succeeded")

    ipa_path = export_dir / "medlingo.ipa"
    if not ipa_path.exists():
        print("→ Exporting IPA…")
        result = subprocess.run([
            "xcodebuild", "-exportArchive",
            "-archivePath", str(archive_path),
            "-exportOptionsPlist", str(export_opts),
            "-exportPath", str(export_dir),
            "-allowProvisioningUpdates",
        ], capture_output=True)

        if result.returncode != 0:
            print(f"  xcodebuild -exportArchive failed (exit {result.returncode}); using fallback…")
            ipa_path = package_ipa_fallback(archive_path, export_dir, build_number)
        else:
            print("  ✓ Export succeeded")

    return ipa_path


def set_export_compliance(client: ASCClient, build_id: str) -> None:
    """Declare HTTPS-only encryption compliance. Required before submission."""
    status, resp = client.patch(
        f"{API_V1}/builds/{build_id}",
        {"data": {"type": "builds", "id": build_id,
                   "attributes": {"usesNonExemptEncryption": False}}}
    )
    if status not in (200, 201):
        raise RuntimeError(f"Export compliance failed: {resp}")
    print("✓ Export compliance set (usesNonExemptEncryption: false)")


def main() -> int:
    issuer = os.environ.get("ASC_ISSUER_ID", DEFAULT_ISSUER)
    key_id = os.environ.get("ASC_KEY_ID", DEFAULT_KEY_ID)
    key_path = Path.home() / f".appstoreconnect/private_keys/AuthKey_{key_id}.p8"
    client = ASCClient(issuer, key_id, key_path)

    skip_upload = os.environ.get("SKIP_IPA_UPLOAD") == "1"

    if not skip_upload:
        if BUILD_NUMBER:
            ipa = build_and_package_ipa(BUILD_NUMBER)
        else:
            ipa = ROOT / "build/export/medlingo.ipa"
        print(f"→ Uploading {ipa.name}…")
        upload_ipa(ipa, issuer, key_id, key_path)

    if BUILD_NUMBER:
        build_id = wait_for_build(client, BUILD_NUMBER)
    elif CONFIG.get("buildId"):
        build_id = CONFIG["buildId"]
    else:
        builds = client.get(f"{API_V1}/apps/{APP_ID}/builds?limit=1&sort=-uploadedDate")
        build_id = builds["data"][0]["id"]

    set_export_compliance(client, build_id)
    attach_build(client, VERSION_ID, build_id)
    upload_listing_screenshots(client)
    update_review_notes(client)
    submission_id = submit_for_review(client)

    print(f"\nResubmission complete. Review submission: {submission_id}")
    print(f"   Build: {BUILD_NUMBER or build_id}")
    print(f"   Resolution Center reply: {REVIEW_REPLY}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
