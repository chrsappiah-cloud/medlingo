#!/usr/bin/env bash
# Capture App Review screenshot for IAP products (Premium paywall).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUTPUT_DIR="${DISTRIBUTION_IAP_OUTPUT_DIR:-$ROOT/distribution/screenshots/iap}"
OUTPUT="${DISTRIBUTION_IAP_SCREENSHOT:-$OUTPUT_DIR/premium-paywall.png}"
SIM_NAME="${SIMULATOR_NAME:-iPhone 17 Pro Max}"

mkdir -p "$OUTPUT_DIR"
bash "$ROOT/scripts/select-xcode.sh"
xcodebuild -downloadPlatform iOS >/dev/null 2>&1 || true

SIM_ID="$(xcrun simctl list devices available | grep "$SIM_NAME (" | head -1 | sed -E 's/.*\(([A-F0-9-]+)\).*/\1/')"
[[ -n "$SIM_ID" ]] || { echo "Simulator not found: $SIM_NAME" >&2; exit 1; }

xcrun simctl boot "$SIM_ID" 2>/dev/null || true
xcrun simctl bootstatus "$SIM_ID" -b

export DISTRIBUTION_IAP_OUTPUT_DIR="$OUTPUT_DIR"
xcodebuild test \
  -project "$ROOT/medlingo.xcodeproj" \
  -scheme medlingo \
  -destination "platform=iOS Simulator,id=$SIM_ID" \
  -only-testing:medlingoUITests/IAPReviewScreenshotTests/testCaptureIAPReviewScreenshot \
  CODE_SIGNING_ALLOWED=NO

if [[ ! -f "$OUTPUT" && -f /tmp/medlingo-iap-screenshots/premium-paywall.png ]]; then
  cp /tmp/medlingo-iap-screenshots/premium-paywall.png "$OUTPUT"
fi
[[ -f "$OUTPUT" ]] || { echo "IAP screenshot missing at $OUTPUT" >&2; exit 1; }
echo "Saved: $OUTPUT"
