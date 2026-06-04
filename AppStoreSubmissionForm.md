# Medlingo - App Store Connect Submission Form

Status: Ready for corrected resubmission
Version: 1.0
Bundle ID: wcs.medlingo
Last updated: 2026-06-05

Use this document to complete App Store Connect. Copy each section into the matching field.

## App Information

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
| Age Rating | 4+ |

## Pricing and Availability

| Field | Value |
|-------|-------|
| Price | Free |

## What's New

```text
Account state has been corrected for App Review. Fresh installs no longer display a pre-existing account, and Sign Out now clears an active session immediately. App Store screenshots and review notes have also been refreshed.
```

## Promotional Text

```text
Master medical terminology with polished lessons, interactive practice labs, visual study tools, tutor discovery, and progress tracking.
```

## Description

```text
Medlingo is your AI-powered medical terminology tutor. Master complex medical vocabulary through engaging lessons, pronunciation practice, and spaced repetition, designed for medical students, nursing professionals, and healthcare workers.

KEY FEATURES

- Structured Stages: progress through anatomy, pathology, pharmacology, and clinical vocabulary.
- Practice Lab: flashcards, word builder, anatomy labeling, quizzes, and case studies.
- Collection Gallery: curated educational artwork and videos for visual study.
- Tutor Sessions: discover tutors and preview booking for live study support.
- Progress Dashboard: track XP, mastery, streaks, and stage completion.
- Core Curriculum: learn without creating an account.

Whether you're preparing for exams, starting clinical rotations, or building healthcare vocabulary, Medlingo makes medical language accessible and engaging.

Medlingo is an educational study aid, not a clinical decision tool. Content supports exam preparation and vocabulary building and does not replace professional medical judgment.
```

## Keywords

```text
medical terminology,nursing,anatomy,medical student,NCLEX,healthcare,flashcards,pronunciation,AI tutor,spaced repetition
```

## URLs

| Field | URL |
|-------|-----|
| Support URL | https://wcs-full.vercel.app |
| Marketing URL | https://wcs-full.vercel.app |
| Privacy Policy URL | https://wcs-full.vercel.app/privacy |

## Screenshots

Upload iPhone screenshots from distribution/screenshots/6.7-inch/ and iPad screenshots from distribution/screenshots/13-inch-iPad/ in this order:

1. 01-learn-home.png
2. 02-practice-lab.png
3. 03-anatomy-labeling.png
4. 04-collection-gallery.png
5. 05-progress-dashboard.png
6. 06-tutor-sessions.png

iPhone dimensions: 1290 x 2796 px
iPad dimensions: 2048 x 2732 px

## App Review Information

| Field | Value |
|-------|-------|
| First Name | Christopher |
| Last Name | Appiah-Thompson |
| Email | christopher.appiahthompson@myworldclass.org |
| Sign-in required? | No |
| Demo account username | Leave blank |
| Demo account password | Leave blank |

### Notes

```text
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
```

## App Privacy

| Data type | Collected | Linked to user | Used for |
|-----------|-----------|----------------|----------|
| Email | Optional | Yes | Account |
| Product interaction | Yes | Yes | First-party analytics |
| Crash data | Optional | No | App functionality |

Tracking: No. The app does not track users across apps or websites owned by other companies.

Full policy: https://wcs-full.vercel.app/privacy

## Age Rating

| Question | Answer |
|----------|--------|
| Cartoon or fantasy violence | None |
| Realistic violence | None |
| Sexual content | None |
| Profanity | None |
| Medical/treatment information | Infrequent/Mild - educational terminology only |
| Gambling | None |
| Unrestricted web access | No |
| Made for Kids | No |

Result: 4+

## Export Compliance

| Question | Answer |
|----------|--------|
| Uses encryption? | Yes, HTTPS only |
| Exempt from export documentation? | Yes |
| Proprietary or non-standard encryption? | No |

In Xcode and App Store Connect: ITSAppUsesNonExemptEncryption = NO.

## Submission Checklist

- [ ] TestFlight build processed.
- [ ] Export compliance answered on build.
- [ ] iPhone screenshots uploaded.
- [ ] iPad screenshots uploaded.
- [ ] App icon uploaded.
- [ ] Privacy Policy URL live.
- [ ] App Review Notes pasted.
- [ ] Resolution Center reply pasted.
- [ ] Submit for Review.
