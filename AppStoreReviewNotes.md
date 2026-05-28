# Medlingo — App Store Review & Distribution Package

## Production Readiness Checklist

| Requirement | Status |
|-------------|--------|
| Minimum iOS 18.0 (broad device support) | ✅ |
| Clean compile (Release) | ✅ |
| Unit tests (45) + performance gates | ✅ |
| UI tests (tab overflow, navigation, flows) | ✅ |
| No CloudKit entitlement (App Store compliance) | ✅ |
| Push entitlement (`production` in entitlements) | ✅ |
| Privacy Policy URL live | ✅ https://wcs-full.vercel.app/privacy |
| Demo / offline learning path for reviewers | ✅ |
| Sign in optional for core content | ✅ |
| IAP / subscriptions (StoreKit 2) | ✅ |
| Age rating 4+ | ✅ |
| CI Gate enforced on `main` | ✅ |
| TestFlight CD on `main` merge | ✅ (requires GitHub secrets) |

---

## App Review Notes (paste into App Store Connect)

**Demo account:** Not required. The app runs fully in learner mode without sign-in. All core study flows (Learn, Practice, Progress, Sessions preview) use built-in sample curriculum.

**How to test:**

1. Launch the app — the **Learn** tab opens with streak, XP, and **Continue Learning**.
2. Tap **Resume** to open Stage 3 (Skeletal System) with lessons and practice cards.
3. Open **Practice** → try **Flashcards**, **Word Builder**, or **Labeling** (anatomy identification with interactive hints).
4. Open **Collection** to browse generated educational artwork (demo gallery when cloud is not configured).
5. Open **Sessions** to preview tutor discovery and booking UI.
6. Open **Progress** for XP, mastery, and stage completion analytics.
7. Open **Account** (may appear under **More** on compact tab bars) for profile and subscription management.

**AI & network behavior:**

- When backend API keys are not configured, the app uses **demo mode**: sample chapters, local collection cache, and simulated AI generation previews. No external AI charges occur during review.
- **Generation Studio** is visible only to administrator roles and is not part of the default learner review path.
- Video tutor sessions use standard AVKit / provider SDK patterns; reviewers can verify UI without joining a live room.

**In-app purchases:**

- Premium subscription and chapter unlock products use **StoreKit 2** with on-device verification. Use a Sandbox Apple ID to test purchases.

**Push notifications:**

- Used for study reminders and session updates. Permission is requested in context, not at launch.

**Third-party content:**

- Medical terminology and anatomy labels are educational originals or properly licensed reference material. No user-generated public content is published without moderation.

**Contact for review questions:**  
Christopher Appiah-Thompson — christopher.appiahthompson@myworldclass.org

---

## Promotional Text (170 characters)

Master medical terminology with luxury design, AI-powered study tools, interactive practice labs, and progress tracking — built for students, nurses, and healthcare professionals.

---

## Description (short hook — first 3 lines)

**Medlingo turns medical language into mastery.**

Learn word roots, anatomy, and clinical vocabulary through structured stages, pronunciation practice, and a practice lab that feels as polished as the best education apps on the App Store — with diamond-and-gold visual design that makes every session rewarding.

---

## What’s New (Version 1.0 — Resubmission)

- **Collection Gallery** — Browse and favorite AI-generated educational artwork and videos.
- **Generation Studio** (Creator) — Administrators can generate medical visuals with guided prompts and style presets.
- **Performance** — Parallel bootstrap, UI-test launch path, and 99th-percentile performance test gates.
- **Reliability** — Full CI/CD with mandatory unit, UI, and quality gates before TestFlight.
- **Purchase Flow Fix** — Upgrade button now properly displays loading state, initiates StoreKit, and shows error alerts on failure. All errors in the purchase chain are now surfaced to the user.

---

## Keywords (optimized)

medical terminology, nursing, anatomy, medical student, NCLEX, healthcare, flashcards, pronunciation, AI tutor, spaced repetition, clinical vocabulary, med school

---

## Review Response Templates

Copy these into **App Store Connect → Resolution Center** when replying to review feedback.

### If asked about AI generation

> Medlingo’s Generation Studio is an optional creator tool for administrators to produce supplementary study visuals. Learners consume curated content in the Collection tab. During review, the app operates in demo mode with preloaded sample artworks; no external inference API is called without configured credentials.

### If asked about medical accuracy disclaimer

> Medlingo is an educational study aid, not a clinical decision tool. A clear disclaimer is presented in onboarding and settings: content supports exam preparation and vocabulary building and does not replace professional medical judgment.

### If asked about data collection

> We collect only account email (optional sign-in), progress analytics, and purchase history. Full details: https://wcs-full.vercel.app/privacy. No tracking across third-party apps. Analytics are first-party and used to improve learning paths.

### If asked about subscriptions

> Premium unlocks all stages, practice modes, and tutor messaging. Users can restore purchases via Account → Restore Purchases (StoreKit). Sandbox testing instructions are documented in App Review Notes above.

### If asked about Upgrade button / purchase flow not responding

> This issue has been fixed in build 202605271300. The Upgrade button now properly shows a loading indicator, initiates the StoreKit purchase sheet, and displays an error alert if the purchase cannot be completed (e.g., products not configured in Sandbox). Previous versions silently swallowed errors due to missing error propagation in the async purchase chain.

### If asked about login / demo access (Guideline 2.1)

> No demo account is required. On first launch, the Learn tab loads sample curriculum immediately. Reviewers can tap Resume, open Practice Lab, Collection, Sessions, and Progress without signing in. Account features (subscription management) are reachable from the Account tab or More menu on compact devices.

### If asked about payment mechanism for tutor sessions (Guideline 2.1 — Information Needed)

> Payment for tutor sessions will be handled through Apple's StoreKit 2 In-App Purchase system. We have defined two consumable products: `com.medlingo.sessions.5pack` (5 Session Pack) and `com.medlingo.sessions.10pack` (10 Session Pack). Users purchase a session pack via StoreKit, and the entitlement is verified server-side through our Supabase backend. No third-party payment processors are used. This integration is currently in development and will be activated in a subsequent update. Premium subscription also includes complimentary tutor sessions as a benefit.

### If asked about one-to-one vs one-to-many session format (Guideline 2.1 — Information Needed)

> The app supports both formats. One-to-one (private) sessions have `seatsAvailable: 1` and use Daily video technology for a private tutor-learner video call. One-to-many (group) sessions support multiple learners (8–10 seats) and are instructor-led group video calls. The format is determined per session by the tutor or administrator. All sessions are carried via video call using Daily's video API.

### If asked about incomplete features or placeholder content (Guideline 2.1)

> All learner-facing tabs show fully interactive demo content: structured stages, practice modes, collection artworks, tutor cards, and progress analytics. Generation Studio is intentionally limited to administrator roles and is not shown in the default learner tab bar. Video session rooms can be verified via Sessions UI without a live call.

### If asked about Guideline 4.3 (spam / duplicate apps)

> Medlingo is a focused medical terminology learning product with a distinctive Practice Lab (labeling, word builder, spaced repetition), Collection gallery, and tutor session discovery. It is not a template or repackaged app; it is the sole Medlingo offering on the App Store.

### If asked about Guideline 5.1.1 (privacy / account deletion)

> Sign-in is optional. Users who create an account can sign out from Account. Account deletion requests can be sent to christopher.appiahthompson@myworldclass.org; we process deletion within 30 days per our privacy policy at https://wcs-full.vercel.app/privacy.

### If asked about push notifications (Guideline 4.5.4)

> Push is used only for study reminders and session-related updates. Permission is requested when the user enables reminders, not at launch. Users can disable notifications in iOS Settings.

### If asked about export compliance / encryption

> The app uses only Apple’s standard HTTPS APIs (URLSession) for network calls. No proprietary encryption is implemented. We have answered export compliance accordingly (standard encryption only, exempt).

### If asked to provide updated screenshots or metadata

> We have uploaded six 6.7" screenshots showing Learn, Practice Lab, Anatomy Labeling, Collection, Sessions, and Progress. Files are generated from the production UI via `scripts/capture-distribution-screenshots.sh` and documented in `distribution/README.md`.

### If rejection cites missing In-App Purchase information

> Subscription products (Premium Monthly/Yearly) unlock all stages and practice modes. Consumable session packs and chapter unlock are documented in App Review Notes. All products use StoreKit 2 with on-device verification. Sandbox Apple ID testing is supported; Restore Purchases is available under Account.

### If rejection cites Guideline 2.1(b) — IAP not submitted for review

> We have submitted all In-App Purchase products referenced in the app for review in App Store Connect, including App Review screenshots for each product. Products: `com.medlingo.premium.monthly`, `com.medlingo.premium.yearly`, `com.medlingo.sessions.5pack`, `com.medlingo.sessions.10pack`, `com.medlingo.chapter.unlock`. A new binary has been uploaded with this submission. Premium is reachable via Account → Premium Plan; Sandbox Apple ID can be used to test Upgrade and Restore Purchases. Full reply text: see `docs/AppStoreIAPResubmission.md`.

---

## TestFlight Release Notes (internal)

**Build 3 — Production candidate**

- Collection + Generation Studio feature set
- CI/CD: mandatory unit + UI tests, CI Gate on main
- UITest stability for compact tab bars (More overflow)
- Launch performance optimizations (`-UITesting` fast path, deferred bootstrap)
- App Store compliance: CloudKit removed from entitlements
