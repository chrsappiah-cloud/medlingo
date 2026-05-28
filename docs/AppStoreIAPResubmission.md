# App Store Resubmission — Guideline 2.1(b) In-App Purchases

**Submission ID:** 610c83c3-b828-4203-b64b-827789899d61  
**Review date:** May 27, 2026  
**Review device:** iPad Air 11-inch (M3)  
**Version reviewed:** 1.0 (202605271300)  
**Resubmission build:** 202605281200+ (see TestFlight after CD merge)

---

## Resolution Center reply (paste into App Store Connect)

```
Hello App Review,

Thank you for the follow-up. We have addressed Guideline 2.1(b) as follows:

1. IN-APP PURCHASE PRODUCTS SUBMITTED FOR REVIEW
   All Premium and related IAP products referenced in the app are now submitted
   for review in App Store Connect with complete metadata and App Review
   screenshots:

   • com.medlingo.premium.monthly — Auto-Renewable Subscription (Premium Monthly)
   • com.medlingo.premium.yearly — Auto-Renewable Subscription (Premium Yearly)
   • com.medlingo.sessions.5pack — Consumable (5 Session Pack)
   • com.medlingo.sessions.10pack — Consumable (10 Session Pack)
   • com.medlingo.chapter.unlock — Non-Consumable (Chapter Unlock)

2. NEW BINARY UPLOADED
   We have uploaded a new build to App Store Connect (build 202605281200 or later)
   with this submission so review can proceed with the IAP products attached.

3. HOW TO TEST PREMIUM (SANDBOX)
   • Open Account (or More → Account on compact layouts / iPad).
   • Tap Premium Plan to open the subscription screen.
   • Subscription products load via StoreKit 2; tap Upgrade on a plan to see the
     native purchase sheet (Sandbox Apple ID).
   • Restore Purchases is available on the same screen.

4. REVIEW SCREENSHOTS FOR IAP
   App Review screenshots for each IAP product are attached in App Store Connect
   (subscription paywall from Account → Premium Plan). See distribution/screenshots/
   for the app listing screenshots.

Core learning flows remain available without sign-in or purchase. Premium unlocks
all stages and practice modes.

Please let us know if you need any additional information.

Best regards,
Christopher Appiah-Thompson
christopher.appiahthompson@myworldclass.org
```

---

## App Store Connect checklist (complete before Submit for Review)

### In-App Purchases (Features → In-App Purchases)

For **each** product ID below:

- [ ] Status is **Ready to Submit** (not Missing Metadata)
- [ ] Display name and description (English U.S.) filled
- [ ] Pricing set
- [ ] **App Review screenshot** uploaded (required — use Premium Plan screen)
- [ ] Product submitted for review (checkbox when submitting app version)

| Product ID | Type | Suggested display name |
|------------|------|------------------------|
| `com.medlingo.premium.monthly` | Auto-renewable subscription | Premium Monthly |
| `com.medlingo.premium.yearly` | Auto-renewable subscription | Premium Yearly |
| `com.medlingo.sessions.5pack` | Consumable | 5 Session Pack |
| `com.medlingo.sessions.10pack` | Consumable | 10 Session Pack |
| `com.medlingo.chapter.unlock` | Non-consumable | Chapter Unlock |

**Subscription group:** Create one group (e.g. "Premium") and add monthly + yearly.

### App version 1.0

- [ ] Select new build (202605281200+) under the version
- [ ] Under **In-App Purchases and Subscriptions**, include all products above
- [ ] Paste App Review Notes from `AppStoreSubmissionForm.md` Section 10
- [ ] Reply in Resolution Center with the message above
- [ ] Submit for Review

---

## IAP review screenshot

Capture on iPhone or iPad simulator:

1. Launch app → **Account** → **Premium Plan**
2. Screenshot showing plan cards and Upgrade buttons (1290×2796 or iPad size per product)

Save as `distribution/screenshots/iap/premium-paywall.png` for upload to each IAP in Connect.
