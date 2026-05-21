#!/usr/bin/env bash
# Prefer newest Xcode on CI runners and local Macs.
set -euo pipefail
for xcode in \
  /Applications/Xcode_26.5.app \
  /Applications/Xcode_26.4.app \
  /Applications/Xcode_26.3.app \
  /Applications/Xcode_26.2.app \
  /Applications/Xcode.app; do
  if [[ -d "$xcode" ]]; then
    if [[ "${CI:-}" == "true" || "${GITHUB_ACTIONS:-}" == "true" ]]; then
      sudo xcode-select -s "$xcode/Contents/Developer"
    else
      xcode-select -p 2>/dev/null | grep -q "${xcode}/Contents/Developer" \
        || sudo xcode-select -s "$xcode/Contents/Developer"
    fi
    xcodebuild -version
    exit 0
  fi
done
echo "No supported Xcode installation found under /Applications" >&2
exit 1
