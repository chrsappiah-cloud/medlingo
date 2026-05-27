# Medlingo — App Store Resubmission Report

**Date:** May 27, 2026
**Version:** 1.0 (Build 202605271200)
**Submission ID:** 65f0002a-4dac-43a1-8689-a4450f91d11f
**Review Device:** iPhone 17 Pro Max / iOS 26.5

---

## Issue 1: Guideline 2.1(a) — Upgrade Button Not Responding

### Root Cause

The "Upgrade" button on the Subscription page silently swallowed all errors. The purchase flow had three compounding issues:

1. **Products not loading:** `StoreKitService.loadProducts()` was called with `try?` in the `.task` modifier, silently discarding any failure (e.g., network error, missing App Store Connect product configuration). If `availableProducts` remained empty, every subsequent purchase attempt would fail.

2. **Missing product error swallowed:** `AppState.handlePurchase(productID:)` threw `StoreError.purchaseFailed` when the product was not found in `availableProducts`, but the caller used `Task { _ = try? await ... }` which silently dropped the error.

3. **No user feedback:** There was no loading indicator, no error alert, and no success confirmation. The button appeared to do nothing.

### Fixes Applied

**Files modified:**

| File | Changes |
|------|---------|
| `Features/Account/AccountView.swift` | Added `isPurchasing` state, `purchaseError` state, and error alert to `SubscriptionView`. Products loading now shows a `ProgressView`. Purchase errors display an alert. `PlanCard` accepts `isLoading` parameter to show a spinner on the button. |
| `Core/Middleware/AppState.swift` | Changed `handlePurchase` to throw `StoreError.productNotFound(productID:)` instead of generic `.purchaseFailed` for better diagnostics. |
| `Core/Payments/StoreKitService.swift` | Made `verifyOnServer()` non-throwing (server verification failure no longer blocks the purchase). Added `productNotFound` case to `StoreError` with a descriptive error message. |

**What the user now sees:**
- Loading spinner while plans load
- Loading spinner on the Upgrade button during purchase
- Error alert if products fail to load or purchase fails
- Clean success path with StoreKit's native sheet

### Verification

- Build: **SUCCEEDED** (Debug-iphonesimulator, arm64)

---

## Issue 2: Guideline 2.1 — Information Needed

### Question 1: Payment mechanism for tutor session bookings

**Draft response:**

> Payment for tutor sessions will be handled through **Apple's StoreKit 2 In-App Purchase system**. We have defined two consumable product types for this purpose:
>
> - `com.medlingo.sessions.5pack` — 5 Session Pack
> - `com.medlingo.sessions.10pack` — 10 Session Pack
>
> Users will purchase a session pack via StoreKit, and the entitlement is verified server-side through our Supabase backend. The booking flow deducts from the user's available session count. This integration is currently in development and will be activated in a subsequent update.
>
> Additionally, **Premium subscription** (auto-renewable, monthly/yearly) includes complimentary tutor sessions as a benefit.
>
> No third-party payment processors (Stripe, etc.) are used. All payments flow through Apple's StoreKit 2.

### Question 2: Session format (one-to-one vs one-to-many)

**Draft response:**

> The app supports **both formats**:
>
> - **One-to-one (private) sessions:** Available tutors can be booked for private, individual sessions. These are modeled with `seatsAvailable: 1`, meaning only one learner can book that session slot. The session room uses Daily video technology for a private tutor-learner video call.
>
> - **One-to-many (group) sessions:** Scheduled group study sessions (e.g., "Cardiology Terminology Deep Dive") support multiple learners (8–10 seats). These are instructor-led group video sessions where all booked learners join the same room.
>
> The format is determined per session by the tutor or administrator when creating it. The `TutorSession` model uses `seatsAvailable` to distinguish: `1` = private/one-to-one, `>1` = group/one-to-many.
>
> All session types are carried via **video call** using Daily's video API, accessible directly within the app.

---

## Resubmission Checklist

- [ ] Build the app as a new version (1.0, build increment)
- [ ] Upload to TestFlight and ensure processing completes
- [ ] Verify all 5 IAP products are **Ready to Submit** in App Store Connect:
  - `com.medlingo.premium.monthly` (Auto-renewable)
  - `com.medlingo.premium.yearly` (Auto-renewable)
  - `com.medlingo.sessions.5pack` (Consumable)
  - `com.medlingo.sessions.10pack` (Consumable)
  - `com.medlingo.chapter.unlock` (Non-consumable)
- [ ] Reply to Apple in Resolution Center with answers to both Guideline 2.1 questions
- [ ] Submit the updated build for review

### How to reply in App Store Connect

1. Go to **App Store Connect** → My Apps → medlingo
2. Navigate to the rejected submission
3. Scroll to **Resolution Center**
4. Reply to Apple's message with the draft responses above
5. After replying, upload the new build and submit for review
