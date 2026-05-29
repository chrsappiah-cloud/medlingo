# App Store Review Response — IAP Removal Explanation

**Date:** May 30, 2026  
**Submission ID:** 72a127f7-1a12-443c-964c-b11a5ba400e7  
**Review date:** May 29, 2026  
**Review device:** iPad Air 11-inch (M3), iPadOS 26.5  
**Version reviewed:** 1.0 (202605271300)  
**New build:** 1.0 (202605301200) — archived and ready for upload

---

## Response to Guideline 2.1(b) — App Completeness (IAP Not Submitted)

> The app includes references to premium plans but the associated In-App Purchase products have not been submitted for review.

**Resolution:** We have removed ALL In-App Purchase functionality from the app. The app no longer references monthly plans, yearly plans, or any subscription products. All chapters and content are now completely free. A new build with IAP removed will be uploaded.

Changes made:
- Deleted `StoreKitService.swift` — entire StoreKit/IAP layer removed
- Rewritten `AccountView.swift` — no purchase/restore buttons, no subscription display
- Removed all premium gating from `ChapterListView.swift` and `ChapterDetailView.swift`
- Removed StoreKit-related scenarios from `AppLaunchConfiguration.swift`
- Removed subscription navigation paths from `NavigationRouter.swift`
- Removed `subscription_review` tab from app entry point
- All 15 chapters are now free with `isPremium: false` and `unlockRule: .free`

We are **not** submitting In-App Purchase products with this resubmission because the app no longer contains purchase functionality.

---

## Response to Guideline 2.1(b) — IAP Bug (Upgrade Button Error)

> An error message was displayed when we tapped on the 'Upgrade' button.

**Resolution:** The 'Upgrade' button has been completely removed from the app. There is no upgrade path, no premium tiers, and no purchase buttons anywhere in the application. All features are available for free.

---

## Summary of Build Changes (v1.0, new build)

| Change | Detail |
|--------|--------|
| IAP Code | 100% removed — `StoreKitService.swift` deleted |
| Account View | Rewritten — no purchases, no restore, no subscription info |
| Chapter Access | All 15 chapters free (`isPremium: false`) |
| Navigation | Subscription review path removed |
| Tab Bar | Subscription tab removed |
| Analytics | Purchase/restore events removed |

---

## Paste-ready reply

See **`Medlingo-AppStoreReviewReply-May30-2026.txt`** on Desktop, or copy from `distribution/` after sync.

---

## New Build Information

- **Version:** 1.0
- **Build number:** 202605301200
- **Device testing:** 209 unit + 5 integration + 9 critical E2E passed on iPhone 17 Pro Max (iOS 26.6)
- **Xcode project:** medlingo.xcodeproj
- **Scheme:** medlingo
- **Deployment target:** iOS 18.0+
