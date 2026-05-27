# Medlingo Distribution Assets

App Store Connect submission package for **Medlingo v1.0**.

## Contents

| Path | Purpose |
|------|---------|
| `screenshots/6.7-inch/` | Required iPhone 6.7" screenshots (1290×2796) |
| `marketing/app-icon-1024.png` | App Store icon (1024×1024) |
| `../AppStoreSubmissionForm.md` | Copy-paste fields for App Store Connect |
| `../AppStoreReviewNotes.md` | Reviewer notes + response templates |
| `../AppStoreMetadata.md` | Listing metadata reference |
| `medlingo-202605271200.ipa` | Release build IPA (v1.0, build 202605271200) |

## Generate screenshots

```bash
cd /Applications/medlingo
bash scripts/capture-distribution-screenshots.sh
```

Uses **iPhone 17 Pro Max** simulator by default. Override with `SIMULATOR_NAME="iPhone 16 Pro Max"`.

## Screenshot order (upload to App Store Connect)

1. `01-learn-home.png` — Learn tab, streak, Continue Learning
2. `02-practice-lab.png` — Practice Lab modes
3. `03-anatomy-labeling.png` — Interactive anatomy labeling
4. `04-collection-gallery.png` — Educational artwork collection
5. `05-progress-dashboard.png` — XP, mastery, stage progress
6. `06-tutor-sessions.png` — Tutor discovery and booking

## Upload checklist

- [ ] 6.7" screenshots uploaded (minimum 3, recommended 6)
- [ ] App icon 1024×1024 (`marketing/app-icon-1024.png`)
- [ ] Fields copied from `AppStoreSubmissionForm.md`
- [ ] TestFlight build processed and selected for submission
