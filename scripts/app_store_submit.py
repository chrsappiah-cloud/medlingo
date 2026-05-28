#!/usr/bin/env python3
"""Automate App Store Connect IAP setup, screenshots, binary upload, and version submission."""

from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_ISSUER = "70c46c69-5d6d-438d-b300-31df2b93163a"
DEFAULT_KEY_ID = "4B8M4ZHLMF"
DEFAULT_APP_ID = "6766951084"
BUNDLE_ID = "wcs.medlingo"
API_V1 = "https://api.appstoreconnect.apple.com/v1"
API_V2 = "https://api.appstoreconnect.apple.com/v2"
LOCALE = "en-AU"

PRODUCTS = {
    "subscriptions": {
        "6773959722": ("com.medlingo.premium.monthly", 9.99),
        "6773959767": ("com.medlingo.premium.yearly", 79.99),
    },
    "inAppPurchases": {
        "6773959277": ("com.medlingo.sessions.5pack", 4.99),
        "6773959673": ("com.medlingo.sessions.10pack", 9.99),
        "6773959856": ("com.medlingo.chapter.unlock", 2.99),
    },
}


class ASCClient:
    def __init__(self, issuer: str, key_id: str, key_path: Path) -> None:
        self.issuer = issuer
        self.key_id = key_id
        self.private_key = key_path.read_text()

    def _token(self) -> str:
        import jwt

        return jwt.encode(
            {
                "iss": self.issuer,
                "iat": int(time.time()),
                "exp": int(time.time()) + 1200,
                "aud": "appstoreconnect-v1",
            },
            self.private_key,
            algorithm="ES256",
            headers={"kid": self.key_id, "typ": "JWT"},
        )

    def _headers(self, content_type: str = "application/json") -> dict[str, str]:
        headers = {"Authorization": f"Bearer {self._token()}"}
        if content_type:
            headers["Content-Type"] = content_type
        return headers

    def get(self, url: str) -> dict:
        req = urllib.request.Request(url, headers=self._headers(content_type=""))
        with urllib.request.urlopen(req, timeout=120) as resp:
            return json.loads(resp.read())

    def post(self, url: str, body: dict) -> tuple[int, dict]:
        data = json.dumps(body).encode()
        req = urllib.request.Request(url, data=data, headers=self._headers(), method="POST")
        try:
            with urllib.request.urlopen(req, timeout=120) as resp:
                return resp.status, json.loads(resp.read())
        except urllib.error.HTTPError as e:
            return e.code, json.loads(e.read().decode())

    def patch(self, url: str, body: dict) -> tuple[int, dict]:
        data = json.dumps(body).encode()
        req = urllib.request.Request(url, data=data, headers=self._headers(), method="PATCH")
        try:
            with urllib.request.urlopen(req, timeout=120) as resp:
                return resp.status, json.loads(resp.read())
        except urllib.error.HTTPError as e:
            return e.code, json.loads(e.read().decode())

    def upload_binary(self, upload_op: dict, file_path: Path) -> None:
        body = upload_op.get("requestBody", {})
        method = upload_op.get("method", "PUT")
        url = upload_op["url"]
        headers = {h["name"]: h["value"] for h in body.get("headers", [])}
        headers["Content-Length"] = str(file_path.stat().st_size)
        data = file_path.read_bytes()
        req = urllib.request.Request(url, data=data, headers=headers, method=method)
        with urllib.request.urlopen(req, timeout=300) as resp:
            resp.read()

    def upload_review_screenshot(self, resource_type: str, resource_id: str, image: Path) -> None:
        if resource_type == "subscriptionAppStoreReviewScreenshots":
            relationships = {
                "subscription": {"data": {"type": "subscriptions", "id": resource_id}}
            }
        else:
            relationships = {
                "inAppPurchaseV2": {"data": {"type": "inAppPurchases", "id": resource_id}}
            }
        status, resp = self.post(
            f"{API_V1}/{resource_type}",
            {
                "data": {
                    "type": resource_type,
                    "attributes": {
                        "fileName": image.name,
                        "fileSize": image.stat().st_size,
                    },
                    "relationships": relationships,
                }
            },
        )
        if status not in (200, 201):
            raise RuntimeError(f"Screenshot reservation failed: {resp}")

        screenshot_id = resp["data"]["id"]
        ops = resp["data"]["attributes"].get("uploadOperations", [])
        if not ops:
            included = resp.get("included", [])
            for item in included:
                ops = item.get("attributes", {}).get("uploadOperations", [])
                if ops:
                    break
        if not ops:
            raise RuntimeError(f"No upload operations for screenshot: {resp}")

        self.upload_binary(ops[0], image)

        status, resp = self.patch(
            f"{API_V1}/{resource_type}/{screenshot_id}",
            {
                "data": {
                    "type": resource_type,
                    "id": screenshot_id,
                    "attributes": {"uploaded": True},
                }
            },
        )
        if status not in (200, 201):
            raise RuntimeError(f"Screenshot commit failed: {resp}")
        print(f"  ✓ screenshot uploaded for {resource_id}")


def capture_iap_screenshot() -> Path:
    out = ROOT / "distribution/screenshots/iap"
    out.mkdir(parents=True, exist_ok=True)
    target = out / "premium-paywall.png"
    env = os.environ.copy()
    env["DISTRIBUTION_OUTPUT_DIR"] = str(out)
    subprocess.run(
        ["bash", str(ROOT / "scripts/capture-distribution-screenshots.sh")],
        cwd=ROOT,
        env=env,
        check=True,
    )
    if not target.exists():
        candidates = list(out.glob("iap-premium-paywall.png")) + list(out.glob("*.png"))
        if not candidates:
            raise FileNotFoundError("IAP screenshot not captured")
        target = candidates[0]
    return target


def upload_ipa(ipa: Path, issuer: str, key_id: str, key_path: Path) -> None:
    cmd = [
        "xcrun", "altool", "--upload-app",
        "-f", str(ipa),
        "-t", "ios",
        "--apiKey", key_id,
        "--apiIssuer", issuer,
        "--private-key", str(key_path),
    ]
    print(f"→ Uploading {ipa} to TestFlight…")
    subprocess.run(cmd, check=True)


def update_review_notes(client: ASCClient, version_id: str, notes_path: Path) -> None:
    notes = notes_path.read_text()
    detail = client.get(f"{API_V1}/appStoreVersions/{version_id}/appStoreReviewDetail")
    detail_id = detail["data"]["id"]
    status, resp = client.patch(
        f"{API_V1}/appStoreReviewDetails/{detail_id}",
        {
            "data": {
                "type": "appStoreReviewDetails",
                "id": detail_id,
                "attributes": {"notes": notes[:4000]},
            }
        },
    )
    if status not in (200, 201):
        raise RuntimeError(f"Review notes update failed: {resp}")
    print("✓ App Review notes updated")


def attach_build(client: ASCClient, version_id: str, build_id: str) -> None:
    status, resp = client.patch(
        f"{API_V1}/appStoreVersions/{version_id}",
        {
            "data": {
                "type": "appStoreVersions",
                "id": version_id,
                "relationships": {
                    "build": {"data": {"type": "builds", "id": build_id}},
                },
            }
        },
    )
    if status not in (200, 201):
        raise RuntimeError(f"Build attach failed: {resp}")
    print(f"✓ Build {build_id} attached to version")


def main() -> int:
    parser = argparse.ArgumentParser(description="Submit Medlingo to App Store Connect")
    parser.add_argument("--issuer", default=os.environ.get("ASC_ISSUER_ID", DEFAULT_ISSUER))
    parser.add_argument("--key-id", default=os.environ.get("ASC_KEY_ID", DEFAULT_KEY_ID))
    parser.add_argument("--key-path", type=Path, default=Path.home() / f".appstoreconnect/private_keys/AuthKey_{DEFAULT_KEY_ID}.p8")
    parser.add_argument("--ipa", type=Path, default=ROOT / "build/export/medlingo.ipa")
    parser.add_argument("--screenshot", type=Path)
    parser.add_argument("--skip-upload", action="store_true")
    parser.add_argument("--skip-screenshots", action="store_true")
    parser.add_argument("--skip-binary", action="store_true")
    args = parser.parse_args()

    client = ASCClient(args.issuer, args.key_id, args.key_path)

    screenshot = args.screenshot
    if not screenshot and not args.skip_screenshots:
        print("→ Capturing IAP review screenshot…")
        screenshot = capture_iap_screenshot()
    elif screenshot is None:
        screenshot = ROOT / "distribution/screenshots/iap/premium-paywall.png"

    if not args.skip_screenshots:
        if not screenshot.exists():
            print(f"Missing screenshot: {screenshot}", file=sys.stderr)
            return 1
        print(f"→ Uploading IAP review screenshot to all products ({screenshot})…")
        for sub_id in PRODUCTS["subscriptions"]:
            client.upload_review_screenshot("subscriptionAppStoreReviewScreenshots", sub_id, screenshot)
        for iap_id in PRODUCTS["inAppPurchases"]:
            client.upload_review_screenshot("inAppPurchaseAppStoreReviewScreenshots", iap_id, screenshot)

    if not args.skip_binary and args.ipa.exists():
        upload_ipa(args.ipa, args.issuer, args.key_id, args.key_path)
    elif not args.skip_binary:
        print(f"IPA not found at {args.ipa}; run scripts/distribute.sh first", file=sys.stderr)

    version_id = "f59c3cca-7268-4944-a5e2-6ba91c02a513"
    notes = ROOT / "docs/AppStoreReviewNotes.md"
    if notes.exists():
        review_block = notes.read_text()
        if "App Review Notes (paste into App Store Connect)" in review_block:
            review_block = review_block.split("App Review Notes (paste into App Store Connect)", 1)[1]
            review_block = review_block.split("---", 1)[0].strip()
        tmp = ROOT / "build/app_review_notes.txt"
        tmp.parent.mkdir(parents=True, exist_ok=True)
        tmp.write_text(review_block[:4000])
        try:
            update_review_notes(client, version_id, tmp)
        except Exception as e:
            print(f"Warning: review notes: {e}")

    builds = client.get(f"{API_V1}/apps/{DEFAULT_APP_ID}/builds?limit=3")
    if builds.get("data"):
        latest = builds["data"][0]["id"]
        try:
            attach_build(client, version_id, latest)
        except Exception as e:
            print(f"Warning: attach build: {e}")

    print("\n✅ Automation complete.")
    print("Manual: App Store Connect → Version 1.0 → In-App Purchases → select all 5 products → Submit for Review")
    print("Manual: Resolution Center → paste docs/AppStoreResolutionCenterReply-2.1b.txt")
    return 0


if __name__ == "__main__":
    sys.exit(main())
