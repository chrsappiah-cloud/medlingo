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
from app_store_submit import ASCClient, API_V1, DEFAULT_APP_ID, DEFAULT_ISSUER, DEFAULT_KEY_ID, attach_build, upload_ipa

CONFIG = json.loads((ROOT / "config/app_store_connect.json").read_text())
VERSION_ID = CONFIG["versionId"]
BUILD_ID = CONFIG["buildId"]
LOCALIZATION_ID = "e3f09bbf-0a42-4e37-8511-77e47903dae5"
IPHONE_DIR = ROOT / "distribution/screenshots/6.7-inch"

SCREENSHOT_TYPES = [
    ("APP_IPHONE_67", IPHONE_DIR, (1290, 2796)),
    ("APP_IPAD_PRO_3GEN_129", IPHONE_DIR, (2048, 2732)),
]

PRODUCT_IDS = list(CONFIG["products"].values())


def resize_screenshot(src: Path, dest: Path, width: int, height: int) -> None:
    dest.parent.mkdir(parents=True, exist_ok=True)
    subprocess.run(
        ["sips", "-z", str(height), str(width), str(src), "--out", str(dest)],
        check=True,
        capture_output=True,
    )


def upload_listing_screenshots(client: ASCClient) -> None:
    print("→ Uploading App Store listing screenshots (iPhone 6.7\" + iPad 12.9\")…")
    sources = sorted(IPHONE_DIR.glob("*.png"))
    if not sources:
        raise FileNotFoundError(f"No screenshots in {IPHONE_DIR}")

    with tempfile.TemporaryDirectory() as tmp:
        tmp_path = Path(tmp)
        for display_type, _, (w, h) in SCREENSHOT_TYPES:
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

            for idx, src in enumerate(sources[:6], start=1):
                img = src
                if display_type.startswith("APP_IPAD"):
                    img = tmp_path / f"ipad_{src.name}"
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
            print(f"  ✓ uploaded {len(sources[:6])} screenshots for {display_type}")


def update_review_notes(client: ASCClient) -> None:
    notes_path = ROOT / "docs/AppStoreResolutionCenterReply-2.1b.txt"
    review_notes = f"""RESUBMISSION — Guideline 2.1(b) IAP fix (Submission 610c83c3-b828-4203-b64b-827789899d61)

{notes_path.read_text()}

HOW TO TEST (no login required):
Learn → Resume → Practice → Collection → Sessions → Progress.
Premium: Account → Premium Plan (StoreKit 2, Sandbox Apple ID). Restore Purchases on same screen.

All five IAP products submitted with review screenshots. Build {CONFIG['buildNumber']}.
"""
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
    subs = client.get(f"{API_V1}/apps/{DEFAULT_APP_ID}/reviewSubmissions")
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
                    "app": {"data": {"type": "apps", "id": DEFAULT_APP_ID}},
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
    print("  ✓ app version added (IAP products are Ready to Submit in Connect)")

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


def main() -> int:
    issuer = os.environ.get("ASC_ISSUER_ID", DEFAULT_ISSUER)
    key_id = os.environ.get("ASC_KEY_ID", DEFAULT_KEY_ID)
    key_path = Path.home() / f".appstoreconnect/private_keys/AuthKey_{key_id}.p8"
    client = ASCClient(issuer, key_id, key_path)

    attach_build(client, VERSION_ID, BUILD_ID)
    upload_listing_screenshots(client)
    update_review_notes(client)
    submission_id = submit_for_review(client)

    ipa = ROOT / "build/export/medlingo.ipa"
    if ipa.exists() and os.environ.get("UPLOAD_IPA") == "1":
        try:
            upload_ipa(ipa, issuer, key_id, key_path)
        except Exception as e:
            print(f"IPA upload skipped: {e}")

    print(f"\n✅ Resubmission complete. Review submission: {submission_id}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
