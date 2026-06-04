# Medlingo - App Store Review Notes

## App Review Notes

Demo account: Not required.

Medlingo opens directly into learner mode. A fresh install should show the learner experience without any existing account state. All core study flows are available without signing in.

How to test:

1. Launch the app. The Learn tab opens with streak, XP, and Continue Learning.
2. Tap Resume to open Stage 3, Skeletal System.
3. Open Practice and try Flashcards, Word Builder, Labeling, Quiz, or Case Studies.
4. Open Collection to browse built-in educational artwork.
5. Open Sessions to preview tutor discovery and booking UI.
6. Open Progress to review XP, mastery, streaks, and stage completion.
7. Open Account. On a clean install it should show Guest learner and No account signed in. The Sign Out button is not shown unless a real session exists.

Account behavior:

- The app clears stale local auth tokens from older builds on launch.
- A clean install or updated install should not appear signed in with a pre-existing account.
- If a real session exists, Sign Out clears the session immediately and returns Account to Guest learner.

AI and network behavior:

- When backend API keys are not configured, the app uses demo mode with sample chapters, local collection data, and simulated generation previews.
- Generation Studio is limited to administrator roles and is hidden from the default learner review path.
- Video session screens can be verified without joining a live room.

Policy links:

- Privacy Policy: https://wcs-full.vercel.app/privacy
- Terms of Service: https://wcs-full.vercel.app/terms

Contact:

Christopher Appiah-Thompson
christopher.appiahthompson@myworldclass.org

## Metadata

Promotional text:

Master medical terminology with polished lessons, interactive practice labs, visual study tools, tutor discovery, and progress tracking.

Description:

Medlingo is an AI-powered medical terminology tutor. Master complex medical vocabulary through structured lessons, pronunciation practice, and spaced repetition, designed for medical students, nursing professionals, and healthcare workers.

Key features:

- Structured stages for anatomy, pathology, pharmacology, and clinical vocabulary.
- Practice Lab with flashcards, word builder, anatomy labeling, quizzes, and case studies.
- Collection gallery with curated educational artwork and study visuals.
- Tutor session discovery and booking previews.
- Progress dashboard for XP, mastery, streaks, and stage completion.
- Core curriculum available without sign-in.

Medlingo is an educational study aid, not a clinical decision tool. Content supports exam preparation and vocabulary building and does not replace professional medical judgment.

What's New:

Account state has been corrected for App Review. Fresh installs no longer display a pre-existing account, and Sign Out now clears an active session immediately. App Store screenshots and review notes have also been refreshed.
