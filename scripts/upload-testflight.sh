#!/usr/bin/env bash
# Upload medlingo.ipa to TestFlight via App Store Connect API.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
IPA="${IPA:-$ROOT/build/export/medlingo.ipa}"
API_KEY="${ASC_KEY_ID:-${APP_STORE_CONNECT_API_KEY_ID:-}}"
ISSUER="${ASC_ISSUER_ID:-${APP_STORE_CONNECT_API_ISSUER_ID:-}}"
KEY_PATH="${ASC_PRIVATE_KEY_PATH:-}"

if [[ -z "$API_KEY" ]]; then
  for f in "$HOME/.appstoreconnect/private_keys"/AuthKey_*.p8; do
    [[ -f "$f" ]] || continue
    API_KEY="$(basename "$f" .p8 | sed 's/AuthKey_//')"
    KEY_PATH="$f"
    break
  done
fi

if [[ -z "$KEY_PATH" && -n "$API_KEY" ]]; then
  KEY_PATH="$HOME/.appstoreconnect/private_keys/AuthKey_${API_KEY}.p8"
fi

if [[ ! -f "$IPA" ]]; then
  echo "IPA not found: $IPA — run scripts/distribute.sh first" >&2
  exit 1
fi

if [[ -z "$API_KEY" || ! -f "$KEY_PATH" ]]; then
  echo "Missing API key. Set ASC_KEY_ID and ASC_PRIVATE_KEY_PATH." >&2
  exit 1
fi

if [[ -z "$ISSUER" ]]; then
  echo "Missing issuer ID. Set ASC_ISSUER_ID (App Store Connect → Users and Access → Integrations)." >&2
  exit 1
fi

echo "Uploading $IPA (key $API_KEY)..."
xcrun altool --upload-app \
  -f "$IPA" \
  -t ios \
  --apiKey "$API_KEY" \
  --apiIssuer "$ISSUER" \
  --private-key "$KEY_PATH"

echo "Upload submitted — check App Store Connect → TestFlight for processing status."
