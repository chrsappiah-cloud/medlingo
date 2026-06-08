#!/usr/bin/env python3
"""Shared App Store Connect helpers for Medlingo binary and version submission."""

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
CONFIG_PATH = ROOT / "config/app_store_connect.json"
CONFIG = json.loads(CONFIG_PATH.read_text()) if CONFIG_PATH.exists() else {}
DEFAULT_ISSUER = CONFIG.get("issuerId", "70c46c69-5d6d-438d-b300-31df2b93163a")
DEFAULT_KEY_ID = CONFIG.get("keyId", "L3Q98J38HJ")
DEFAULT_APP_ID = CONFIG.get("appId", "6766951084")
DEFAULT_VERSION_ID = CONFIG.get("versionId", "f59c3cca-7268-4944-a5e2-6ba91c02a513")
BUNDLE_ID = CONFIG.get("bundleId", "wcs.medlingo")
API_V1 = "https://api.appstoreconnect.apple.com/v1"
API_V2 = "https://api.appstoreconnect.apple.com/v2"
LOCALE = "en-AU"


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
                "exp": int(time.time()) + 1190,
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

    def delete(self, url: str) -> tuple[int, dict]:
        req = urllib.request.Request(url, headers=self._headers(content_type=""), method="DELETE")
        try:
            with urllib.request.urlopen(req, timeout=120) as resp:
                body = resp.read()
                return resp.status, json.loads(body) if body else {}
        except urllib.error.HTTPError as e:
            body = e.read().decode()
            return e.code, json.loads(body) if body else {}

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


def upload_ipa(ipa: Path, issuer: str, key_id: str, key_path: Path) -> None:
    cmd = [
        "xcrun", "altool", "--upload-app",
        "-f", str(ipa),
        "-t", "ios",
        "--apiKey", key_id,
        "--apiIssuer", issuer,
        "--private-key", str(key_path),
    ]
    print(f"Uploading {ipa} to TestFlight...")
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
    print("App Review notes updated")


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
    print(f"Build {build_id} attached to version")


def main() -> int:
    parser = argparse.ArgumentParser(description="Upload Medlingo binary and update review notes")
    parser.add_argument("--issuer", default=os.environ.get("ASC_ISSUER_ID", DEFAULT_ISSUER))
    parser.add_argument("--key-id", default=os.environ.get("ASC_KEY_ID", DEFAULT_KEY_ID))
    parser.add_argument("--key-path", type=Path)
    parser.add_argument("--ipa", type=Path, default=ROOT / "build/export/medlingo.ipa")
    parser.add_argument("--skip-binary", action="store_true")
    parser.add_argument("--review-notes", type=Path, default=ROOT / "AppStoreReviewNotes.md")
    args = parser.parse_args()

    key_path = args.key_path or Path.home() / f".appstoreconnect/private_keys/AuthKey_{args.key_id}.p8"
    client = ASCClient(args.issuer, args.key_id, key_path)

    if not args.skip_binary:
        if not args.ipa.exists():
            print(f"IPA not found at {args.ipa}; run scripts/distribute.sh first", file=sys.stderr)
            return 1
        upload_ipa(args.ipa, args.issuer, args.key_id, key_path)

    if args.review_notes.exists():
        update_review_notes(client, DEFAULT_VERSION_ID, args.review_notes)

    builds = client.get(f"{API_V1}/apps/{DEFAULT_APP_ID}/builds?limit=1&sort=-uploadedDate")
    if builds.get("data"):
        attach_build(client, DEFAULT_VERSION_ID, builds["data"][0]["id"])

    print("Automation complete.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
