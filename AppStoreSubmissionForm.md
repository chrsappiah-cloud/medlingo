# Medlingo — App Store Connect Submission Form

**Status:** Ready for resubmission  
**Version:** 1.0 (Build 202605271200)  
**Bundle ID:** `wcs.medlingo`  
**Last updated:** 2026-05-27

Use this document to complete App Store Connect. Copy each section into the matching field.

---

## 1. App Information

| Field | Value |
|-------|-------|
| Name | Medlingo |
| Subtitle | Medical Terminology Made Easy |
| Bundle ID | wcs.medlingo |
| SKU | medlingo-001 |
| Primary Language | English (U.S.) |
| Category | Education |
| Secondary Category | Medical |
| Content Rights | Does not contain third-party content requiring rights |
| Age Rating | 4+ (see questionnaire answers below) |

---

## 2. Pricing and Availability

| Field | Value |
|-------|-------|
| Price | Free (with In-App Purchases) |
| Availability | All territories (or restrict per your business policy) |

---

## 3. Version 1.0 — What's New

```
Initial release — Structured medical terminology stages, interactive Practice Lab (flashcards, word builder, labeling, quizzes), Collection gallery for study visuals, tutor session discovery, and StoreKit 2 Premium subscriptions. Polished diamond-and-gold UI with performance tuned to top-tier education apps.
```

---

## 4. Promotional Text (170 characters max)

```
Master medical terminology with luxury design, AI-powered study tools, interactive practice labs, and progress tracking — built for students, nurses, and healthcare professionals.
```

---

## 5. Description

```
Medlingo is your AI-powered medical terminology tutor. Master complex medical vocabulary through engaging lessons, pronunciation practice, and spaced repetition — designed for medical students, nursing professionals, and healthcare workers.

KEY FEATURES

• Structured Stages — Progress through anatomy, pathology, pharmacology, and clinical vocabulary with gem-themed stage progression

• Practice Lab — Flashcards, Word Builder, Anatomy Labeling, Quizzes, and Case Studies to reinforce retention

• Collection Gallery — Browse curated educational artwork and videos for visual learning

• Tutor Sessions — Discover tutors and preview booking for live study sessions

• Progress Dashboard — Track XP, mastery, streaks, and stage completion

• Premium Subscription — Unlock all stages and practice modes via StoreKit 2 (monthly/yearly)

• Offline-Friendly Demo — Core curriculum loads without sign-in for study anywhere

Whether you're preparing for exams, starting clinical rotations, or building healthcare vocabulary, Medlingo makes medical language accessible and engaging.

Medlingo is an educational study aid, not a clinical decision tool. Content supports exam preparation and vocabulary building and does not replace professional medical judgment.
```

---

## 6. Keywords (100 characters max, comma-separated, no spaces after commas)

```
medical terminology,nursing,anatomy,medical student,NCLEX,healthcare,flashcards,pronunciation,AI tutor,spaced repetition
```

---

## 7. Support, Marketing, and Privacy URLs

| Field | URL |
|-------|-----|
| Support URL | https://wcs-full.vercel.app |
| Marketing URL | https://wcs-full.vercel.app |
| Privacy Policy URL | https://wcs-full.vercel.app/privacy |

---

## 8. Screenshots (6.7" Display — required)

Upload from `distribution/screenshots/6.7-inch/` in this order:

| # | File | Caption (optional, per locale) |
|---|------|--------------------------------|
| 1 | `01-learn-home.png` | Your medical terminology journey starts here |
| 2 | `02-practice-lab.png` | Interactive Practice Lab for every learning style |
| 3 | `03-anatomy-labeling.png` | Master anatomy with interactive labeling |
| 4 | `04-collection-gallery.png` | Visual study aids in your Collection |
| 5 | `05-progress-dashboard.png` | Track XP, streaks, and mastery |
| 6 | `06-tutor-sessions.png` | Connect with expert tutors |

**Dimensions:** 1290 × 2796 px (portrait)  
**Generate:** `bash scripts/capture-distribution-screenshots.sh`

---

## 9. App Preview (optional)

Not required for initial submission. Add later if you produce a 15–30s screen recording on the same 6.7" device.

---

## 10. App Review Information

| Field | Value |
|-------|-------|
| First Name | Christopher |
| Last Name | Appiah-Thompson |
| Phone | *(your business phone)* |
| Email | christopher.appiahthompson@myworldclass.org |
| Sign-in required? | No — core flows work without account |
| Demo account username | *(leave blank — not required)* |
| Demo account password | *(leave blank — not required)* |

### Notes (paste full block)

```
RESUBMISSION NOTES — Guideline 2.1(a) fix applied in build 202605271200:
The Upgrade button on the Subscription page now properly responds with a loading
indicator, initiates the StoreKit purchase sheet, and displays error alerts if
the purchase cannot be completed. All errors in the async purchase chain are
now surfaced to the user.

Demo account: Not required. The app runs fully in learner mode without sign-in. All core study flows use built-in sample curriculum.

HOW TO TEST
1. Launch — Learn tab shows streak, XP, and Continue Learning.
2. Tap Resume — opens Stage 3 (Skeletal System) with lessons and practice.
3. Practice tab — Flashcards, Word Builder, Labeling (tap Cranium for hint demo).
4. Collection tab — demo educational artwork gallery.
5. Sessions tab — tutor discovery and booking UI.
6. Progress tab — XP, mastery, 7-day streak, stage analytics.
7. Account tab — may appear under More on compact devices; profile and Premium Plan.

AI & NETWORK
- Without API keys, app uses demo mode: sample chapters, local collection, no external AI charges during review.
- Generation Studio is admin-only and hidden for default learner role.
- Video sessions use AVKit; UI verifiable without joining a live room.

IN-APP PURCHASES
- StoreKit 2: com.medlingo.premium.monthly, com.medlingo.premium.yearly, session packs, chapter unlock.
- Test with Sandbox Apple ID. Restore via Account → Restore Purchases.

PUSH NOTIFICATIONS
- Study reminders and session updates; permission requested in context, not at launch.

EXPORT COMPLIANCE
- App uses only standard HTTPS (URLSession). No custom encryption → answer "No" to proprietary encryption.

CONTACT
Christopher Appiah-Thompson — christopher.appiahthompson@myworldclass.org
```

---

## 11. App Privacy (summary for questionnaire)

| Data type | Collected | Linked to user | Used for |
|-----------|-----------|--------------|----------|
| Email | Optional (sign-in) | Yes | Account |
| Purchase history | Yes | Yes | App functionality |
| Product interaction | Yes | Yes | Analytics (first-party) |
| Crash data | Optional | No | App functionality |

**Tracking:** No — we do not track users across apps/websites owned by other companies.

Full policy: https://wcs-full.vercel.app/privacy

---

## 12. Age Rating Questionnaire (typical answers)

| Question | Answer |
|----------|--------|
| Cartoon or fantasy violence | None |
| Realistic violence | None |
| Sexual content | None |
| Profanity | None |
| Medical/treatment information | Infrequent/Mild — educational terminology only |
| Gambling | None |
| Unrestricted web access | No |
| Made for Kids | No |

**Result:** 4+

---

## 13. Export Compliance

| Question | Answer |
|----------|--------|
| Uses encryption? | Yes (HTTPS only) |
| Exempt from export documentation? | Yes — qualifies for mass-market exemption |
| Proprietary/non-standard encryption? | No |

In Xcode / App Store Connect: **ITSAppUsesNonExemptEncryption = NO** (standard HTTPS only).

---

## 14. In-App Purchases (reference)

| Product ID | Type | Display name (suggested) |
|------------|------|--------------------------|
| com.medlingo.premium.monthly | Auto-renewable | Premium Monthly |
| com.medlingo.premium.yearly | Auto-renewable | Premium Yearly |
| com.medlingo.sessions.5pack | Consumable | 5 Session Pack |
| com.medlingo.sessions.10pack | Consumable | 10 Session Pack |
| com.medlingo.chapter.unlock | Non-consumable | Chapter Unlock |

Ensure each product is **Ready to Submit** with localized display name and description in App Store Connect.

---

## 15. Build selection

| Field | Value |
|-------|-------|
| Version | 1.0 |
| Build | 202605271200 (from distribution pipeline) |
| Copyright | © 2026 Christopher Appiah-Thompson |

---

## 16. Submission checklist

- [ ] TestFlight build **Processed** (no missing compliance)
- [ ] Export compliance answered on build
- [ ] Push Notifications: `aps-environment` = **production** in provisioning profile
- [ ] Screenshots uploaded (6.7" — min. 3)
- [ ] App icon 1024×1024 uploaded
- [ ] Privacy Policy URL live
- [ ] IAP products configured and reviewed
- [ ] App Review Notes pasted (Section 10)
- [ ] Submit for Review

---

## 17. Review response templates

See **`AppStoreReviewNotes.md`** → *Review Response Templates* for copy-paste replies to common App Review questions (AI generation, medical disclaimer, data collection, subscriptions).
