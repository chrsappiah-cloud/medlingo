# Medlingo Distribution Guide

## Local build (this Mac)

Project path: `/Applications/medlingo/medlingo.xcodeproj`

```bash
cd /Applications/medlingo
xcodebuild -downloadPlatform iOS          # platform dependencies
bash scripts/distribute.sh                # archive + IPA (build/export/medlingo.ipa)
ASC_ISSUER_ID=your-issuer bash scripts/upload-testflight.sh   # optional upload
```

Upload the IPA via **Transporter** (Mac App Store), **Xcode Organizer** (`open build/medlingo.xcarchive`), or:

```bash
xcrun altool --upload-app -f build/export/medlingo.ipa -t ios \
  --apiKey YOUR_KEY_ID --apiIssuer YOUR_ISSUER_ID \
  --private-key ~/.appstoreconnect/private_keys/AuthKey_YOUR_KEY_ID.p8
```

## GitHub → TestFlight (automated)

1. Merge PR to `main` (requires **CI Gate** green).
2. CD workflow (`CD - Deploy to TestFlight`) runs automatically on `main` push.
3. Required GitHub **production** environment secrets:
   - `BUILD_CERTIFICATE_BASE64`, `P12_PASSWORD`, `BUILD_PROVISION_PROFILE_BASE64`, `KEYCHAIN_PASSWORD`
   - `TEAM_ID`, `PROVISIONING_PROFILE_NAME`
   - `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_PRIVATE_KEY`
4. Manual trigger: **Actions → CD - Deploy to TestFlight → Run workflow**.

## App Store Connect submission

| Field | Value |
|-------|--------|
| Version | 1.0 |
| Build | 202605271300 (local) / auto-incremented in CD |
| Bundle ID | `wcs.medlingo` |
| Category | Education / Medical |
| Age | 4+ |

Copy from **`AppStoreSubmissionForm.md`** (full field-by-field guide) or:
- **`AppStoreReviewNotes.md`** → App Review Notes + response templates
- **`AppStoreMetadata.md`** → metadata reference
- **`AppStoreSubmissionForm.md`** → Promotional Text, Description, Keywords, privacy, age rating, export compliance

## Distribution screenshots

Generate six App Store screenshots (6.7" / 1290×2796) from the simulator:

```bash
bash scripts/capture-distribution-screenshots.sh
```

Output: `distribution/screenshots/6.7-inch/` (see `distribution/README.md` for upload order).

App icon for Connect: `distribution/marketing/app-icon-1024.png`

## Pre-submission checklist

- [ ] TestFlight build processed (no missing compliance)
- [ ] Push Notifications: set `aps-environment` to **production** in Apple Developer + regenerate profile
- [ ] Screenshots generated and uploaded (6.7" required — `distribution/screenshots/6.7-inch/`)
- [ ] App icon 1024×1024 uploaded (`distribution/marketing/app-icon-1024.png`)
- [ ] `AppStoreSubmissionForm.md` fields pasted into App Store Connect
- [ ] Privacy Policy URL: https://wcs-full.vercel.app/privacy
- [ ] Sandbox IAP tested
- [ ] Export compliance answered (standard HTTPS only → No)

## Reviewer demo path (no login)

Learn → Resume → Practice → Collection → Sessions → Progress → Account (More tab on small phones).
