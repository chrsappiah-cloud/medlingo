#!/usr/bin/env bash
# Create and boot an iOS Simulator for CI with accessibility warm-up.
set -euo pipefail

DEVICE_TYPE="${CI_SIM_DEVICE:-com.apple.CoreSimulator.SimDeviceType.iPhone-16}"
SIM_NAME="${CI_SIM_NAME:-CI iPhone Medlingo}"

xcodebuild -downloadPlatform iOS 2>/dev/null || true

RUNTIME_ID=""
for attempt in 1 2 3 4 5; do
  RUNTIME_ID=$(xcrun simctl list runtimes available -j | python3 -c "
import json, sys
ios = [r for r in json.load(sys.stdin).get('runtimes', [])
       if r.get('isAvailable') and 'iOS' in r.get('name', '')]
if ios:
    ios.sort(key=lambda r: r['name'], reverse=True)
    print(ios[0]['identifier'])
")
  if [[ -n "$RUNTIME_ID" ]]; then break; fi
  echo "Waiting for iOS runtime (attempt $attempt)..."
  sleep 15
done

if [[ -z "$RUNTIME_ID" ]]; then
  echo "::error::No iOS simulator runtime available after retries"
  xcrun simctl list runtimes
  exit 1
fi

# Reuse an existing CI sim when possible (faster, more stable AX).
SIM_ID=$(xcrun simctl list devices available -j | python3 -c "
import json, os, sys
name = os.environ['SIM_NAME']
for d in json.load(sys.stdin).get('devices', {}).values():
    for dev in d:
        if dev.get('name') == name and dev.get('isAvailable'):
            print(dev['udid'])
            raise SystemExit
" SIM_NAME="$SIM_NAME" || true)

if [[ -z "${SIM_ID:-}" ]]; then
  SIM_ID=$(xcrun simctl create "$SIM_NAME" "$DEVICE_TYPE" "$RUNTIME_ID")
fi

xcrun simctl boot "$SIM_ID" 2>/dev/null || true
xcrun simctl bootstatus "$SIM_ID" -b

# Reduce UI-test flakes: settle SpringBoard and accessibility before xcodebuild test.
xcrun simctl bootstatus "$SIM_ID" -b
sleep 5
xcrun simctl ui "$SIM_ID" appearance light 2>/dev/null || true
xcrun simctl launch "$SIM_ID" com.apple.springboard 2>/dev/null || true
sleep 3
xcrun simctl launch "$SIM_ID" com.apple.Preferences 2>/dev/null || true
sleep 5
xcrun simctl terminate "$SIM_ID" com.apple.Preferences 2>/dev/null || true

if [[ -n "${GITHUB_ENV:-}" ]]; then
  echo "SIM_ID=$SIM_ID" >> "$GITHUB_ENV"
fi
export SIM_ID
