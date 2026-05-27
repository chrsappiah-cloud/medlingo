#!/usr/bin/env bash
# Capture App Store screenshots (6.7" / 1290×2796) via UI tests on iPhone Pro Max simulator.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

OUTPUT_DIR="${DISTRIBUTION_OUTPUT_DIR:-$ROOT/distribution/screenshots/6.7-inch}"
SIM_NAME="${SIMULATOR_NAME:-iPhone 17 Pro Max}"
SCHEME="medlingo"
PROJECT="medlingo.xcodeproj"

STAGING="/tmp/medlingo-distribution-screenshots"
mkdir -p "$OUTPUT_DIR"
rm -rf "$STAGING"
mkdir -p "$STAGING"

echo "→ Selecting Xcode…"
bash "$ROOT/scripts/select-xcode.sh"

echo "→ Ensuring iOS simulator runtime…"
xcodebuild -downloadPlatform iOS >/dev/null 2>&1 || true

SIM_ID="$(xcrun simctl list devices available | grep "$SIM_NAME (" | head -1 | sed -E 's/.*\(([A-F0-9-]+)\).*/\1/')"
if [[ -z "$SIM_ID" ]]; then
  echo "No simulator named '$SIM_NAME' found. Set SIMULATOR_NAME to a Pro Max device." >&2
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
  2>&1 | tee "$DERIVED/xcodebuild-test.log" | xcpretty --color 2>/dev/null || cat "$DERIVED/xcodebuild-test.log"
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
  python3 - "$XCRESULT" "$OUTPUT_DIR" <<'PY'
import json, os, subprocess, sys
xcresult, out_dir = sys.argv[1], sys.argv[2]
raw = subprocess.check_output(
    ["xcrun", "xcresulttool", "get", "test-results", "tests", "--path", xcresult, "--format", "json"],
    text=True,
)
data = json.loads(raw)
attachments = []
def walk(node):
    if isinstance(node, dict):
        for item in node.get("attachments", []) or []:
            attachments.append(item)
        for value in node.values():
            walk(value)
    elif isinstance(node, list):
        for item in node:
            walk(item)
walk(data)
for item in attachments:
    ref = item.get("payloadRef") or item.get("payloadReference") or {}
    ref_id = ref.get("id")
    if isinstance(ref_id, dict):
        ref_id = ref_id.get("_value")
    name = item.get("name")
    if isinstance(name, dict):
        name = name.get("_value")
    name = name or "screenshot"
    if not ref_id:
        continue
    dest = os.path.join(out_dir, f"{name}.png")
    subprocess.run(
        ["xcrun", "xcresulttool", "export", "attachments", "--path", xcresult, "--output-path", dest, "--id", ref_id],
        check=False,
    )
PY
  fi
fi

if compgen -G "$OUTPUT_DIR/*.png" >/dev/null; then
  echo "→ Resizing screenshots to App Store 6.7\" size (1290×2796)…"
  for png in "$OUTPUT_DIR"/*.png; do
    sips -z 2796 1290 "$png" >/dev/null
  done
fi

echo ""
if compgen -G "$OUTPUT_DIR/*.png" >/dev/null; then
  echo "Screenshots saved to: $OUTPUT_DIR"
  ls -la "$OUTPUT_DIR"/*.png
  exit 0
fi

echo "No screenshots captured." >&2
exit "${TEST_EXIT:-1}"
