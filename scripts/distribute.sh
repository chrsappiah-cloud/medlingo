#!/usr/bin/env bash
# Archive and export Medlingo for App Store Connect / TestFlight.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT="$ROOT/medlingo.xcodeproj"
SCHEME="medlingo"
ARCHIVE="$ROOT/build/medlingo.xcarchive"
EXPORT_DIR="$ROOT/build/export"
BUILD_NUMBER="${BUILD_NUMBER:-$(date +%Y%m%d%H%M)}"
TEAM_ID="${TEAM_ID:-TM2WG7HH96}"

mkdir -p "$ROOT/build"

echo "Project: $PROJECT"
echo "Build number: $BUILD_NUMBER"

xcodebuild -downloadPlatform iOS

xcodebuild archive \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Release \
  -archivePath "$ARCHIVE" \
  -destination 'generic/platform=iOS' \
  -allowProvisioningUpdates \
  DEVELOPMENT_TEAM="$TEAM_ID" \
  CURRENT_PROJECT_VERSION="$BUILD_NUMBER"

EXPORT_OPTIONS="$ROOT/build/ExportOptions.plist"
cat > "$EXPORT_OPTIONS" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>method</key>
  <string>app-store-connect</string>
  <key>teamID</key>
  <string>$TEAM_ID</string>
  <key>uploadSymbols</key>
  <true/>
  <key>destination</key>
  <string>export</string>
</dict>
</plist>
PLIST

rm -rf "$EXPORT_DIR"
mkdir -p "$EXPORT_DIR"

# Prefer Homebrew rsync; Xcode export can fail on macOS OpenRSync (missing --extended-attributes).
if [[ -x /opt/homebrew/bin/rsync ]]; then
  export PATH="/opt/homebrew/bin:$PATH"
fi

set +e
xcodebuild -exportArchive \
  -archivePath "$ARCHIVE" \
  -exportOptionsPlist "$EXPORT_OPTIONS" \
  -exportPath "$EXPORT_DIR" \
  -allowProvisioningUpdates
EXPORT_STATUS=$?
set -e

if [[ $EXPORT_STATUS -ne 0 || ! -f "$EXPORT_DIR/medlingo.ipa" ]]; then
  echo "xcodebuild export failed (status $EXPORT_STATUS); packaging IPA manually..."
  ENTITLEMENTS="$ROOT/build/ExportEntitlements.plist"
  cat > "$ENTITLEMENTS" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>application-identifier</key>
  <string>$TEAM_ID.wcs.medlingo</string>
  <key>aps-environment</key>
  <string>production</string>
  <key>beta-reports-active</key>
  <true/>
  <key>com.apple.developer.team-identifier</key>
  <string>$TEAM_ID</string>
  <key>get-task-allow</key>
  <false/>
</dict>
</plist>
PLIST
  STAGING="$ROOT/build/ipa-staging"
  rm -rf "$STAGING"
  mkdir -p "$STAGING/Payload"
  ditto "$ARCHIVE/Products/Applications/medlingo.app" "$STAGING/Payload/medlingo.app"
  codesign -f -s "Apple Distribution" --entitlements "$ENTITLEMENTS" "$STAGING/Payload/medlingo.app"
  (
    cd "$STAGING"
    zip -qr "$EXPORT_DIR/medlingo.ipa" Payload
  )
fi

echo "IPA: $EXPORT_DIR/medlingo.ipa"
echo "Upload with: xcrun altool --upload-app -f $EXPORT_DIR/medlingo.ipa -t ios --apiKey KEY --apiIssuer ISSUER"
