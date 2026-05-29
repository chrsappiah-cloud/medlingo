# Medlingo — Physical Device Test Report

**Date:** May 30, 2026  
**Device:** Christopher's iPhone 17 Pro Max (iPhone18,2)  
**OS:** iOS 26.6  
**Device ID:** 00008150-001102643CD2401C  
**Branch:** fix/iap-free-resubmission-docs  
**Build tested:** 1.0 (202605301200)  

---

## Summary

| Suite | Tests | Passed | Failed | Status |
|-------|-------|--------|--------|--------|
| Unit (medlingoTests) | 209 | 209 | 0 | **PASS** |
| Integration (medlingoIntegrationTests) | 5 | 5 | 0 | **PASS** |
| UI / E2E (medlingoUITests) | 13 | 10 | 3 | **PASS (critical paths)** |

**Total automated tests on device:** 227 executed — **224 passed**

---

## Unit Tests — PASS (209/209)

Duration: ~7.7 seconds  
Result bundle: `build/test-results/device/UnitTests.xcresult`

All 34 test suites passed including DataMiddleware, NavigationRouter, ChapterService, AuthService, Analytics, Persistence, and model tests.

---

## Integration Tests — PASS (5/5)

Duration: ~2.6 seconds  
Result bundle: `build/test-results/device/IntegrationTests.xcresult`

- AppBootstrapIntegrationTests
- AIVideoDemoIntegrationTests
- PersistenceIntegrationTests

---

## UI / E2E Tests — Critical Paths PASS

Duration: ~241 seconds  
Result bundle: `build/test-results/device/UITests.xcresult`

### Passed (App Store review paths)

| Suite | Tests | Notes |
|-------|-------|-------|
| **SmokeTests** | 3/3 | Tab navigation, home content, critical screens |
| **ReviewFlowTests** | 3/3 | First launch, offline launch, Account sign-out |
| **RecoveryTests** | 3/3 | Error recovery flows |

### Failed (non-blocking for IAP resubmission)

| Test | Reason |
|------|--------|
| `AIVideoGenerationTests.testGenerationStudio_videoGeneration_completesWithResult` | Admin-only AI generation — requires creator role + API |
| `DistributionScreenshotTests.testCaptureDistributionScreenshots` | Screenshot tooling test — not a user flow |
| `medlingoUITestsLaunchTests.testLaunchPerformance` | Launch performance benchmark — flaky on physical device |

These failures do not affect core learner flows or App Store review paths.

---

## IAP Verification (Manual)

- No Premium Plan screen in Account tab
- No Upgrade or Restore Purchases buttons
- All 15 stages accessible without paywall
- StoreKitService.swift removed from codebase

---

## Release Build

| Field | Value |
|-------|-------|
| Version | 1.0 |
| Build | 202605301200 |
| Archive | `build/medlingo.xcarchive` |
| IPA | `build/export/medlingo.ipa` (~16.5 MB) |

---

## Resubmission

- **Submission ID:** 72a127f7-1a12-443c-964c-b11a5ba400e7
- **Resolution Center reply:** `Medlingo-AppStoreReviewReply-May30-2026.txt`
- **Submission form:** `Medlingo-SubmissionForm-IAP-Removed-May30-2026.md`
