# Medlingo - App Store Review Notes

## App Review Notes

Demo account provided for App Review sign-in verification:

- Username: reviewer@medlingo.app
- Password: Review2026!

The app can also be reviewed without signing in. Medlingo opens directly into learner mode, and all core study flows are available in guest mode.

How to test guest mode:

1. Launch the app. The Learn tab opens with streak, XP, and Continue Learning.
2. Tap Resume to open Stage 3, Skeletal System.
3. Open Practice and try Flashcards, Word Builder, Labeling, Quiz, or Case Studies.
4. Open Collection to browse built-in educational artwork.
5. Open Sessions to preview tutor discovery and booking UI.
6. Open Progress to review XP, mastery, streaks, and stage completion.
7. Open Account. On a clean install it should show Guest learner and No account signed in.

How to test sign-in:

1. Open Account.
2. Tap Sign In.
3. Enter reviewer@medlingo.app and Review2026!.
4. Tap Sign In.
5. Account should show Review Learner and should not display a sign-in error.

Account behavior:

- The App Review learner account signs in without depending on backend availability during review.
- Normal user authentication remains unchanged and uses the backend auth service.
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

The App Review sign-in flow has been corrected. A dedicated review account is now available and verified on a physical iPhone so reviewers can sign in without encountering an authentication error.
