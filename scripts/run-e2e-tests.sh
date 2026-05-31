#!/usr/bin/env bash
# Run full Medlingo test suite (unit + integration + UI) on simulator and/or device.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT="$ROOT/medlingo.xcodeproj"
SCHEME="medlingo"
RESULTS="$ROOT/build/test-results"
SIM_ID="${SIM_ID:-2668601A-9C66-4F0D-995B-167F681F530E}"
DEVICE_ID="${DEVICE_ID:-00008150-001102643CD2401C}"

mkdir -p "$RESULTS/simulator" "$RESULTS/device"

run_suite() {
  local label="$1"
  local dest="$2"
  local out="$3"
  local extra_args=("${@:4}")

  echo "==> Running E2E tests on $label"
  echo "    Destination: $dest"

  if xcodebuild test \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -destination "$dest" \
    -only-testing:medlingoTests \
    -only-testing:medlingoIntegrationTests \
    -only-testing:medlingoUITests \
    -parallel-testing-enabled NO \
    -maximum-concurrent-test-simulator-destinations 1 \
    "${extra_args[@]}" \
    -resultBundlePath "$out" \
    2>&1 | tee "${out}.log"; then
    echo "==> $label: PASSED"
    xcrun xcresulttool get test-results summary --path "$out" 2>/dev/null || true
    return 0
  else
    echo "==> $label: FAILED (see ${out}.log)"
    xcrun xcresulttool get test-results summary --path "$out" 2>/dev/null || true
    return 1
  fi
}

FAILED=0

run_suite "iPhone Simulator" \
  "platform=iOS Simulator,id=$SIM_ID" \
  "$RESULTS/simulator/FullE2E.xcresult" \
  CODE_SIGNING_ALLOWED=NO || FAILED=1

run_suite "Physical iPhone" \
  "platform=iOS,id=$DEVICE_ID" \
  "$RESULTS/device/FullE2E.xcresult" \
  -allowProvisioningUpdates || FAILED=1

exit "$FAILED"
