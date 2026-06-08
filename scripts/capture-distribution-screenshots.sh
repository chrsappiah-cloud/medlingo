#!/usr/bin/env bash
# Capture App Store screenshots via UI tests.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

DEVICE_FAMILY="${DISTRIBUTION_DEVICE_FAMILY:-iphone}"
case "$DEVICE_FAMILY" in
  iphone)
    DEFAULT_OUTPUT_DIR="$ROOT/distribution/screenshots/6.7-inch"
    DEFAULT_SIM_NAME="iPhone 17 Pro Max"
    TARGET_WIDTH=1290
    TARGET_HEIGHT=2796
    ;;
  ipad)
    DEFAULT_OUTPUT_DIR="$ROOT/distribution/screenshots/13-inch-iPad"
    DEFAULT_SIM_NAME="iPad Pro 13-inch (M5)"
    TARGET_WIDTH=2048
    TARGET_HEIGHT=2732
    ;;
  *)
    echo "Unsupported DISTRIBUTION_DEVICE_FAMILY '$DEVICE_FAMILY'. Use 'iphone' or 'ipad'." >&2
    exit 1
    ;;
esac

OUTPUT_DIR="${DISTRIBUTION_OUTPUT_DIR:-$DEFAULT_OUTPUT_DIR}"
SIM_NAME="${SIMULATOR_NAME:-$DEFAULT_SIM_NAME}"
SCHEME="medlingo"
PROJECT="medlingo.xcodeproj"

STAGING="/tmp/medlingo-distribution-screenshots-$DEVICE_FAMILY"
mkdir -p "$OUTPUT_DIR"
find "$OUTPUT_DIR" -maxdepth 1 -type f -name '*.png' -delete
rm -rf "$STAGING"
mkdir -p "$STAGING"

echo "→ Selecting Xcode…"
bash "$ROOT/scripts/select-xcode.sh"

echo "→ Ensuring iOS simulator runtime…"
xcodebuild -downloadPlatform iOS >/dev/null 2>&1 || true

SIM_ID="$(xcrun simctl list devices available | grep "$SIM_NAME (" | head -1 | sed -E 's/.*\(([A-F0-9-]+)\).*/\1/')"
if [[ -z "$SIM_ID" ]]; then
  echo "No simulator named '$SIM_NAME' found. Set SIMULATOR_NAME to an available $DEVICE_FAMILY simulator." >&2
  exit 1
fi

echo "→ Booting $SIM_NAME ($SIM_ID)…"
xcrun simctl boot "$SIM_ID" 2>/dev/null || true
xcrun simctl bootstatus "$SIM_ID" -b

DERIVED="$ROOT/build/DerivedData-Screenshots"
rm -rf "$DERIVED"
mkdir -p "$DERIVED"

echo "→ Running distribution screenshot tests…"
export DISTRIBUTION_OUTPUT_DIR="$STAGING"
set +e
xcodebuild test \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -destination "platform=iOS Simulator,id=$SIM_ID" \
  -derivedDataPath "$DERIVED" \
  -only-testing:medlingoUITests/DistributionScreenshotTests/testCaptureDistributionScreenshots \
  2>&1 | tee "$DERIVED/xcodebuild-test.log"
TEST_EXIT=${PIPESTATUS[0]}
set -e

if compgen -G "$STAGING/*.png" >/dev/null; then
  cp "$STAGING"/*.png "$OUTPUT_DIR"/
elif compgen -G "$OUTPUT_DIR/*.png" >/dev/null; then
  echo "→ Screenshots already present in output directory."
else
  echo "→ Attempting to extract screenshots from xcresult attachments…"
  XCRESULT="$(find "$DERIVED/Logs/Test" -name '*.xcresult' -type d 2>/dev/null | sort | tail -1)"
  if [[ -n "$XCRESULT" ]]; then
    EXTRACTED="$STAGING/xcattachments"
    mkdir -p "$EXTRACTED"
    xcrun xcresulttool export attachments --path "$XCRESULT" --output-path "$EXTRACTED" >/dev/null || true
    python3 - "$EXTRACTED" "$OUTPUT_DIR" <<'PY'
import json, shutil, sys
from pathlib import Path

src_dir = Path(sys.argv[1])
out_dir = Path(sys.argv[2])
manifest = src_dir / "manifest.json"
if not manifest.exists():
    raise SystemExit(0)

for suite in json.loads(manifest.read_text()):
    for attachment in suite.get("attachments", []):
        exported = attachment.get("exportedFileName", "")
        suggested = attachment.get("suggestedHumanReadableName", "")
        if not exported.endswith(".png") or not suggested[:2].isdigit():
            continue
        name = suggested.split("_0_", 1)[0]
        if not name.endswith(".png"):
            name += ".png"
        shutil.copy2(src_dir / exported, out_dir / name)
PY
  fi
fi

if compgen -G "$OUTPUT_DIR/*.png" >/dev/null; then
  echo "→ Resizing screenshots to App Store size (${TARGET_WIDTH}×${TARGET_HEIGHT})…"
  for png in "$OUTPUT_DIR"/*.png; do
    sips -z "$TARGET_HEIGHT" "$TARGET_WIDTH" "$png" >/dev/null
  done
fi

echo ""
if compgen -G "$OUTPUT_DIR/*.png" >/dev/null; then
  echo "Screenshots saved to: $OUTPUT_DIR"
  ls -la "$OUTPUT_DIR"/*.png
  exit 0
fi

echo "No screenshots captured." >&2
if [[ "${TEST_EXIT:-0}" -eq 0 ]]; then
  exit 1
fi
exit "$TEST_EXIT"
