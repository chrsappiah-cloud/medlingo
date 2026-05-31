#!/usr/bin/env bash
# Build, upload, and submit Medlingo for IAP-free App Store review.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_NUMBER="${BUILD_NUMBER:-202605311300}"
DESKTOP="$HOME/Desktop"
STAMP="May31-2026"

echo "==> Medlingo IAP-free resubmission (build $BUILD_NUMBER)"

# 1. Generate PDF + desktop copies
REPLY="$ROOT/distribution/AppStoreReviewReply-May31-2026.txt"
E2E="$ROOT/build/test-results/E2ETestReport-May31-2026.md"
mkdir -p "$DESKTOP/Medlingo-Resubmission-$STAMP"

cp "$REPLY" "$DESKTOP/Medlingo-Resubmission-$STAMP/AppStoreReviewReply-$STAMP.txt"
cp "$REPLY" "$DESKTOP/Medlingo-AppStoreReviewReply-$STAMP.txt"
[[ -f "$E2E" ]] && cp "$E2E" "$DESKTOP/Medlingo-Resubmission-$STAMP/E2ETestReport-$STAMP.md"

if command -v pandoc >/dev/null; then
  pandoc "$REPLY" -o "$DESKTOP/Medlingo-AppStoreReviewReply-$STAMP.pdf" \
    -V geometry:margin=1in -V fontsize=11pt
  cp "$DESKTOP/Medlingo-AppStoreReviewReply-$STAMP.pdf" \
    "$DESKTOP/Medlingo-Resubmission-$STAMP/"
  echo "✓ PDF saved to Desktop"
fi

# 2. Archive and export IPA
export BUILD_NUMBER
bash "$ROOT/scripts/distribute.sh"

# 3. Upload + attach build + submit via App Store Connect API
python3 "$ROOT/scripts/app_store_resubmit.py"

echo ""
echo "Done. Desktop copies: $DESKTOP/Medlingo-Resubmission-$STAMP/"
echo "Resolution Center: paste $REPLY in App Store Connect"
