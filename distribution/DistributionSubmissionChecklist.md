# Medlingo Distribution Submission Checklist

**Date:** May 30, 2026  
**Version:** 1.0 (new build — IAP removed)  
**Submission ID:** 72a127f7-1a12-443c-964c-b11a5ba400e7  
**Review date:** May 29, 2026  
**Review device:** iPad Air 11-inch (M3), iPadOS 26.5  
**Rejected build:** 202605271300  

---

## Pre-Submission Checks

- [x] All IAP/StoreKit code removed from codebase
- [ ] All unit tests passing on simulator
- [ ] All unit tests passing on physical device
- [ ] Archive builds successfully (Release configuration)
- [ ] No compilation errors (warnings only)

## App Store Connect Actions

- [ ] Upload new IPA via Xcode or Transporter (increment build number)
- [ ] Set Pricing to **Free** (no In-App Purchases)
- [ ] Update **What's New** — IAP removed, all content free
- [ ] Update **Description** — remove Premium / StoreKit references
- [ ] Update **App Review Notes** — paste from submission form (Section 9)
- [ ] Update **App Privacy** — mark purchase history as not collected
- [ ] Do **not** submit IAP products with this version
- [ ] Reply to App Review in Resolution Center (see Desktop `.txt` file)
- [ ] Submit for review

## App Review Response

**Desktop copies (May 30, 2026):**
- `~/Desktop/Medlingo-AppStoreReviewReply-May30-2026.txt` — paste into Resolution Center
- `~/Desktop/Medlingo-AppStoreReviewReply-May30-2026.md` — formatted reference
- `~/Desktop/Medlingo-SubmissionForm-IAP-Removed-May30-2026.md` — full submission form

**Repo:** `distribution/AppStoreResponse_iap-removed.md`

### Key Points for Resolution Center Reply

1. All IAP has been removed from the app — we are not submitting IAP products
2. No monthly/yearly plans or premium tiers exist anymore
3. All content is free — no paywall, no Upgrade button, no Restore Purchases
4. New binary uploaded without any purchase functionality
5. No Sandbox Apple ID required for review

---

## Post-Submission

- [ ] Monitor CI/CD pipeline for build validation
- [ ] Track review status in App Store Connect
- [ ] Prepare for release once approved
