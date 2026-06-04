# Medlingo Distribution Guide

Project path: `/Applications/medlingo/medlingo.xcodeproj`

## Local Build

```bash
cd /Applications/medlingo
bash scripts/distribute.sh
```

The exported app archive is written under `build/`.

## App Store Connect

Use these files for the current submission:

- `AppStoreSubmissionForm.md`
- `AppStoreReviewNotes.md`
- `AppStoreMetadata.md`
- `distribution/AppStoreReviewReply-Jun05-2026.txt`

## Screenshots

Generate device-specific screenshots:

```bash
bash scripts/capture-distribution-screenshots.sh
DISTRIBUTION_DEVICE_FAMILY=ipad bash scripts/capture-distribution-screenshots.sh
```

Output:

- `distribution/screenshots/6.7-inch/`
- `distribution/screenshots/13-inch-iPad/`

## Review Checklist

- [ ] Build processed in TestFlight.
- [ ] Correct build selected for version 1.0.
- [ ] App Review Notes pasted from `AppStoreReviewNotes.md`.
- [ ] Resolution Center reply pasted from `distribution/AppStoreReviewReply-Jun05-2026.txt`.
- [ ] iPhone screenshots uploaded.
- [ ] iPad screenshots uploaded.
- [ ] App icon uploaded.
- [ ] Privacy Policy URL set to `https://wcs-full.vercel.app/privacy`.
- [ ] Support URL set to `https://wcs-full.vercel.app`.
- [ ] Export compliance answered.
