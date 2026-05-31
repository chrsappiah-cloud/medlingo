# Medlingo — App Store Resubmission Package

**Date:** May 30, 2026  
**Version:** 1.0  
**Build:** 202605301200  
**Submission ID:** 72a127f7-1a12-443c-964c-b11a5ba400e7  

---

## Files on Desktop

| File | Action |
|------|--------|
| `Medlingo-AppStoreReviewReply-May30-2026.txt` | Paste into App Store Connect → Resolution Center |
| `Medlingo-SubmissionForm-IAP-Removed-May30-2026.md` | Copy fields into App Store Connect listing |
| `Medlingo-DeviceTestReport-May30-2026.md` | Test verification record |
| `medlingo-1.0-202605301200.ipa` | Upload via Transporter or Xcode Organizer |
| `unit-tests.log`, `integration-tests.log`, `ui-tests.log` | Test logs from iPhone 17 Pro Max |

---

## Step 1 — Upload Build

API upload failed (401 auth). Upload manually:

**Option A — Transporter (recommended)**
1. Open **Transporter** app on Mac
2. Drag `medlingo-1.0-202605301200.ipa` onto Transporter
3. Click **Deliver**
4. Wait for processing in App Store Connect → TestFlight

**Option B — Xcode Organizer**
1. Open Xcode → Window → Organizer
2. Or open archive: `/Applications/medlingo/build/medlingo.xcarchive`
3. Distribute App → App Store Connect → Upload

---

## Step 2 — App Store Connect Updates

### Pricing
- Set to **Free** (no In-App Purchases)

### Version 1.0 — What's New
```
Resubmission — All content is now completely free.

• Removed all In-App Purchases and subscription flows
• All 15 study stages and Practice Lab modes available at no cost
• Account screen simplified — no premium plans or upgrade buttons
• Verified on iPhone 17 Pro Max and iPad
```

### App Review Notes
Copy from `Medlingo-SubmissionForm-IAP-Removed-May30-2026.md` Section 9.

Key line: **No In-App Purchases. No Sandbox Apple ID needed.**

### Build Selection
- Version: **1.0**
- Build: **202605301200** (select after processing)

### App Privacy
- Mark **Purchase history** as **Not collected**

### Do NOT
- Submit IAP products with this version
- Reference Premium, StoreKit, or subscriptions in metadata

---

## Step 3 — Reply to Apple

1. Go to App Store Connect → **Medlingo** → **Activity**
2. Open the rejected submission (ID `72a127f7-1a12-443c-964c-b11a5ba400e7`)
3. Click **Reply** in Resolution Center
4. Paste entire contents of `Medlingo-AppStoreReviewReply-May30-2026.txt`

---

## Step 4 — Submit for Review

- [ ] Build 202605301200 processed in TestFlight
- [ ] Build selected on Version 1.0
- [ ] Pricing = Free (no IAP)
- [ ] Description updated (no subscription language)
- [ ] App Review Notes updated
- [ ] Resolution Center reply sent
- [ ] Click **Submit for Review**

---

## Test Results (iPhone 17 Pro Max, iOS 26.6)

| Suite | Result |
|-------|--------|
| Unit tests | 209/209 passed |
| Integration tests | 5/5 passed |
| Smoke + Review Flow + Recovery | 9/9 passed |
| Full UI suite | 10/13 passed (3 non-critical failures: AI admin, screenshot tool, launch perf) |

---

## GitHub

PR #9: https://github.com/chrsappiah-cloud/medlingo/pull/9  
Branch: `fix/iap-free-resubmission-docs`  
Merge after CI Gate passes, then tag release if desired.
