#!/usr/bin/env bash
# Capture App Review screenshot for IAP products (Premium paywall).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUTPUT="${DISTRIBUTION_IAP_SCREENSHOT:-$ROOT/distribution/screenshots/iap/premium-paywall.png}"
SIM_NAME="${SIMULATOR_NAME:-iPhone 17 Pro Max}"

mkdir -p "$(dirname "$OUTPUT")"
bash "$ROOT/scripts/select-xcode.sh"
xcodebuild -downloadPlatform iOS >/dev/null 2>&1 || true

SIM_ID="$(xcrun simctl list devices available | grep "$SIM_NAME (" | head -1 | sed -E 's/.*\(([A-F0-9-]+)\).*/\1/')"
[[ -n "$SIM_ID" ]] || { echo "Simulator not found: $SIM_NAME" >&2; exit 1; }

xcrun simctl boot "$SIM_ID" 2>/dev/null || true
xcrun simctl bootstatus "$SIM_ID" -b

DERIVED="$ROOT/build/DerivedData-IAP-Screenshot"
rm -rf "$DERIVED"

echo "→ Building and launching for IAP screenshot…"
xcodebuild build \
  -project "$ROOT/medlingo.xcodeproj" \
  -scheme medlingo \
  -destination "platform=iOS Simulator,id=$SIM_ID" \
  -derivedDataPath "$DERIVED" \
  CODE_SIGNING_ALLOWED=NO >/dev/null

APP="$DERIVED/Build/Products/Debug-iphonesimulator/medlingo.app"
xcrun simctl install "$SIM_ID" "$APP"
xcrun simctl launch "$SIM_ID" wcs.medlingo || true
sleep 4

echo "→ Open Account → Premium Plan manually, then press Enter to capture…"
read -r _

xcrun simctl io "$SIM_ID" screenshot "$OUTPUT"
echo "Saved: $OUTPUT"
echo "Upload this file to each IAP product in App Store Connect → App Review Screenshot."
