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

## What’s New (Version 1.0)

- **Collection Gallery** — Browse and favorite AI-generated educational artwork and videos.
- **Generation Studio** (Creator) — Administrators can generate medical visuals with guided prompts and style presets.
- **Performance** — Parallel bootstrap, UI-test launch path, and 99th-percentile performance test gates.
- **Reliability** — Full CI/CD with mandatory unit, UI, and quality gates before TestFlight.

---

## Keywords (optimized)

medical terminology, nursing, anatomy, medical student, NCLEX, healthcare, flashcards, pronunciation, AI tutor, spaced repetition, clinical vocabulary, med school

---

## Review Response Templates

### If asked about AI generation

> Medlingo’s Generation Studio is an optional creator tool for administrators to produce supplementary study visuals. Learners consume curated content in the Collection tab. During review, the app operates in demo mode with preloaded sample artworks; no external inference API is called without configured credentials.

### If asked about medical accuracy disclaimer

> Medlingo is an educational study aid, not a clinical decision tool. A clear disclaimer is presented in onboarding and settings: content supports exam preparation and vocabulary building and does not replace professional medical judgment.

### If asked about data collection

> We collect only account email (optional sign-in), progress analytics, and purchase history. Full details: https://wcs-full.vercel.app/privacy. No tracking across third-party apps. Analytics are first-party and used to improve learning paths.

### If asked about subscriptions

> Premium unlocks all stages, practice modes, and tutor messaging. Users can restore purchases via Account → Restore Purchases (StoreKit). Sandbox testing instructions are documented in App Review Notes above.

---

## TestFlight Release Notes (internal)

**Build 3 — Production candidate**

- Collection + Generation Studio feature set
- CI/CD: mandatory unit + UI tests, CI Gate on main
- UITest stability for compact tab bars (More overflow)
- Launch performance optimizations (`-UITesting` fast path, deferred bootstrap)
- App Store compliance: CloudKit removed from entitlements
