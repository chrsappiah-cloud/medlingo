# In-App Purchase Metadata — App Store Connect

Copy into **Features → In-App Purchases** for each product. Upload the same **App Review screenshot** (`distribution/screenshots/iap/premium-paywall.png`) to every product unless Apple requests product-specific screens.

---

## Subscription group

| Field | Value |
|-------|-------|
| Reference name | Premium |
| Group name (display) | Premium |

Add both subscription products to this group. Set yearly as higher service level if prompted.

---

## com.medlingo.premium.monthly

| Field | Value |
|-------|-------|
| Type | Auto-Renewable Subscription |
| Reference name | Premium Monthly |
| Product ID | com.medlingo.premium.monthly |
| Subscription duration | 1 month |
| Display name | Premium Monthly |
| Description | Unlock all medical terminology stages, practice modes, and premium study features. Billed monthly. Cancel anytime in Settings. |
| Review notes (optional) | Shown on Account → Premium Plan. StoreKit 2. Test with Sandbox Apple ID. |

---

## com.medlingo.premium.yearly

| Field | Value |
|-------|-------|
| Type | Auto-Renewable Subscription |
| Reference name | Premium Yearly |
| Product ID | com.medlingo.premium.yearly |
| Subscription duration | 1 year |
| Display name | Premium Yearly |
| Description | Best value: full access to all stages and practice modes for one year. Save compared to monthly. Cancel anytime in Settings. |
| Review notes (optional) | Same paywall as monthly. Recommended default plan on subscription screen. |

---

## com.medlingo.sessions.5pack

| Field | Value |
|-------|-------|
| Type | Consumable |
| Reference name | 5 Session Pack |
| Product ID | com.medlingo.sessions.5pack |
| Display name | 5 Session Pack |
| Description | Five live tutor video sessions for medical terminology study. Consumed when booking a session. |
| Review notes (optional) | Session packs will be purchasable from Sessions when live booking is enabled. Currently defined for future use; Premium includes study access without packs. |

---

## com.medlingo.sessions.10pack

| Field | Value |
|-------|-------|
| Type | Consumable |
| Reference name | 10 Session Pack |
| Product ID | com.medlingo.sessions.10pack |
| Display name | 10 Session Pack |
| Description | Ten live tutor video sessions. Best value for regular learners booking tutor sessions. |
| Review notes (optional) | Same as 5 Session Pack. |

---

## com.medlingo.chapter.unlock

| Field | Value |
|-------|-------|
| Type | Non-Consumable |
| Reference name | Chapter Unlock |
| Product ID | com.medlingo.chapter.unlock |
| Display name | Chapter Unlock |
| Description | Permanently unlock a single premium study stage without a subscription. |
| Review notes (optional) | Alternative to Premium subscription for individual stage access. |

---

## Submit with app version

1. Each product → **Ready to Submit** (metadata + pricing + review screenshot).
2. App version **1.0** → **In-App Purchases and Subscriptions** → add all five products.
3. Select new binary build.
4. Paste reply from `docs/AppStoreResolutionCenterReply-2.1b.txt` in Resolution Center.
5. **Submit for Review**.
