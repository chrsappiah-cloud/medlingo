# Apple Review Workflow Report
**Project:** Medlingo v1.0 · **Date:** 2026-06-05 · **Branch:** fix/iap-free-resubmission-docs · **Commit:** 9554e9a

> Telemetry mapped against the 7-step Claude workflow: Frame → Decompose → Converse → Review → Test → Iterate → Automate.

---

## Step 1 — Frame Your Objective

**Trigger:** Apple Review rejection on Submission ID `9c5cdbf2`, reviewed 2026-06-04.

| Guideline | Stated violation |
|---|---|
| 2.1(a) | Account screen displayed a named user profile on fresh install |
| 2.1(b) | Paid-product / recurring-billing references present |
| 3.1.2(c) | In-app purchase references in app and metadata |

**Objective set:** Fix all three violations, verify on physical device, and resubmit the same version (1.0) without opening a new version record.

**Time to frame:** ~2 min (reading rejection docs, `AppStoreReviewReply-Jun05-2026.txt`, source files)

---

## Step 2 — Decompose the Tasks

Issues broken into discrete, assignable work items:

| # | Task | File(s) | Owner |
|---|---|---|---|
| 1 | Fix hardcoded "C" avatar — shows even for guest users | `AccountView.swift:62` | Code |
| 2 | Fix double `ModelContainer` causing crash-on-launch in all UI tests | `medlingoApp.swift:34-44` | Code |
| 3 | Add missing `import Combine` (build failure) | `AppLifecycleOrchestrator.swift:1` | Code |
| 4 | Update `tapTab` for iOS 26 tab bar accessibility change | `UITestCaseBase.swift`, `DistributionScreenshotTests.swift` | Tests |
| 5 | Remove `hittable` from NSPredicate format strings (invalid key path) | `UITestCaseBase.swift`, `SmokeTests.swift` | Tests |
| 6 | Build release archive, sign with distribution cert, upload build | `build/export-202606051430/` | Distribution |
| 7 | Update review reply with real test results, submit via ASC API | `distribution/AppStoreReviewReply-Jun05-2026.txt` | Distribution |

**Total decomposed tasks:** 7  
**Dependencies identified:** Tasks 2–5 must pass before 6; task 7 depends on 6.

---

## Step 3 — Start the Conversation

**Approach:** Iterative — fix one failure class at a time and immediately verify on device before proceeding to the next class.

Build 1 → install → run tests → read failures → fix → repeat until green.

**Conversation loops:** 3
- Loop 1: `import Combine` → build passes, install, first test run (crashes everywhere)
- Loop 2: Double `ModelContainer` → crashes gone, new failure class exposed (iOS 26 tab bar)
- Loop 3: `hittable` NSPredicate → all 10 tests green

**Blocking questions resolved:**
1. Why does the app crash in ~1.5s? → Two `ModelContainer` instances opening the same SQLite store.
2. Why is "Practice" tab not found? → iOS 26 removed `UITabBar` from the accessibility tree; `app.tabBars` returns empty.
3. Why does `hittable == true` throw? → Not a valid XCUIElement NSPredicate key path; must be checked in Swift.

---

## Step 4 — Review with Claude

**Code review findings actioned before submission:**

| Finding | Severity | Resolution |
|---|---|---|
| `Text("C")` hardcoded in avatar — triggers 2.1(a) | **High** (rejection) | Dynamic initial / `person.fill` for guest |
| `init()` creates second `ModelContainer` for same store | **High** (crash) | Reuse `sharedModelContainer` |
| `import Combine` missing | **High** (build failure) | Added |
| `hittable` in NSPredicate | **Medium** (runtime error) | Removed from all predicates |
| `app.tabBars` — iOS 26 incompatible | **Medium** (test failure) | Replaced with `app.buttons.matching(pred)` |
| `institutional` UnlockRule — flagged as potential 2.1(b) risk | **Low** | Confirmed: `isStageUnlocked` always returns `true`; not a paid gate |

**Items confirmed not violations:**
- `GenerationStudioView.lockedView` — role-gated (admin only), not payment-gated ✓
- `chapterUnlocked` analytics event — internal event name, not visible UI ✓
- `unlockRule: .sequential` — progression mechanic, no payment ✓

---

## Step 5 — Test and Verify

**Device:** Christopher's iPhone · iOS 26.6 · UDID `00008150-001102643CD2401C`  
**Build tested:** Debug `202606051430`  
**Run date/time:** 2026-06-05 09:16–09:21

| Test | Suite | Result | Duration |
|---|---|---|---|
| `testBackgroundThenForeground_appSurvives` | RecoveryTests | ✅ PASS | 7.6s |
| `testExpiredTokenSeed_launchStillShowsAccount` | RecoveryTests | ✅ PASS | 28.1s |
| `testPracticeLab_afterTabSwitch_remainsReachable` | RecoveryTests | ✅ PASS | 16.7s |
| `testAccount_cleanLaunchShowsGuestAndNoSignOut` | ReviewFlowTests | ✅ PASS | 28.1s |
| `testAccount_signOutClearsAuthenticatedSession` | ReviewFlowTests | ✅ PASS | 33.4s |
| `testFirstLaunch_cleanInstall_showsLearnHome` | ReviewFlowTests | ✅ PASS | 16.8s |
| `testOfflineLaunch_appRemainsNavigable` | ReviewFlowTests | ✅ PASS | 12.9s |
| `testHomeScreen_criticalContentVisible` | SmokeTests | ✅ PASS | 4.9s |
| `testLaunch_navigatesMainTabsWithoutCrash` | SmokeTests | ✅ PASS | 38.8s |
| `testTabNavigation_criticalScreensOpen` | SmokeTests | ✅ PASS | 61.6s |

**Total: 10 passed · 0 failed · 0 skipped**  
**Total wall time:** ~4m 18s

### Failure class progression (before → after)

| Run | Crashes | Tab not found | Predicate error | Passed |
|---|---|---|---|---|
| Run 1 (pre-fix) | 7 | 2 | 0 | 1 |
| Run 2 (Combine + ModelContainer) | 0 | 0 | 8 | 2 |
| Run 3 (predicate fix) | 0 | 0 | 0 | **10** |

---

## Step 6 — Redefine and Iterate

**Iteration 1 → 2: Crash fix**  
Root cause: `medlingoApp.init()` created `ModelContainer` #2 for the same SwiftData persistent store already opened by `sharedModelContainer`. Fixed: reuse the existing container.

**Iteration 2 → 3: iOS 26 tab bar**  
Root cause: iOS 26 no longer emits `UITabBar` in the XCTest accessibility tree. `app.tabBars.firstMatch` returns empty. Fixed: use `app.buttons.matching(NSPredicate(format: "label == %@", name)).firstMatch` as the primary path, with legacy `app.tabBars` as fallback for older iOS.

**Iteration 3 → green: NSPredicate key path**  
Root cause: `hittable` is not a valid key path for `XCUIElement` NSPredicate queries. Fixed: remove from all predicates; check `.isHittable` in Swift after `waitForExistence`.

**Distribution iteration:**  
`xcodebuild -exportArchive` fails at `IDEDistributionCopyAppleProvidedContentStep` (rsync EOF — same known issue as build `202605311300`). Mitigated: manual `.app` → `Payload/` → re-sign with `Apple Distribution: Christopher Appiah-Thompson (TM2WG7HH96)` + embed App Store provisioning profile → zip IPA → `xcrun altool --upload-app`.

---

## Step 7 — BONUS: Automate Your Workflow

### What was automated this cycle

| Step | Automation | Script / Hook |
|---|---|---|
| Build + archive | `xcodebuild archive -configuration Release` | `scripts/app_store_resubmit.py` |
| IPA packaging fallback | Manual sign + zip when export rsync fails | `build/ExportOptions-*.plist` + `codesign` |
| Screenshot upload | ASC API `appScreenshotSets` | `scripts/app_store_resubmit.py` |
| Review notes update | ASC API `appStoreReviewDetails` | `scripts/app_store_resubmit.py` |
| Export compliance | ASC API PATCH `builds.usesNonExemptEncryption` | inline API call |
| Review submission | ASC API `reviewSubmissions` | `scripts/app_store_resubmit.py` |

### Automation gaps to close for future iOS projects

| Gap | Recommended fix | Priority |
|---|---|---|
| `xcodebuild -exportArchive` rsync failure (recurring) | Add `IDEDistributionCopyAppleProvidedContent` bypass directly to `app_store_resubmit.py` — detect exit code 70, auto-fall-through to manual IPA packaging | **High** |
| Export compliance not set on new builds | Patch `builds.usesNonExemptEncryption = false` immediately after upload in resubmit script, before submission attempt | **High** |
| Test run not integrated into CI gate | Add `xcodebuild test -only-testing:medlingoUITests/ReviewFlowTests,SmokeTests,RecoveryTests` as a required GitHub Actions check on `main` and PRs targeting `main` | **High** |
| iOS 26 tab bar compatibility checked manually | Add `@available` guard in `UITestCaseBase.tapTab` that auto-selects strategy by OS version | **Medium** |
| Physical device test requires manual USB | Register device in ASC, add it to the provisioning profile, enable GitHub Actions self-hosted runner | **Low** |

### Recommended `.github/workflows/ios-review-gate.yml` for future projects

```yaml
name: iOS Review Gate
on:
  push:
    branches: [main, fix/**]
  pull_request:
    branches: [main]

jobs:
  build-and-test:
    runs-on: macos-15
    steps:
      - uses: actions/checkout@v4
      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode.app
      - name: Build
        run: |
          xcodebuild -project medlingo.xcodeproj -scheme medlingo \
            -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
            -configuration Debug build
      - name: Run review-path tests
        run: |
          xcodebuild test -project medlingo.xcodeproj -scheme medlingo \
            -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
            -only-testing:medlingoUITests/ReviewFlowTests \
            -only-testing:medlingoUITests/SmokeTests \
            -only-testing:medlingoUITests/RecoveryTests \
            -resultBundlePath build/test-results/review-gate.xcresult
      - name: Upload result bundle
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: review-gate-${{ github.sha }}
          path: build/test-results/review-gate.xcresult

  account-state-check:
    runs-on: macos-15
    steps:
      - uses: actions/checkout@v4
      - name: Check for hardcoded user strings
        run: |
          # Fail if any View file has a hardcoded name string that bypasses auth state
          ! grep -rn 'Text("C")\|Text("Christopher")\|Text("Admin")' \
            medlingo/Features/ --include="*.swift"
      - name: Check for IAP references
        run: |
          ! grep -rn 'StoreKit\|SKProduct\|SKPayment\|subscription\|billing' \
            medlingo/ --include="*.swift" -l
```

---

## Submission outcome

| Field | Value |
|---|---|
| Build | `202606051430` |
| Build ID | `19a4526d-cf11-4bd6-8eb1-c4c54c3d4454` |
| Submission ID | `6ccab951-fb09-4bfc-9b9f-6cedf945bda0` |
| Screenshots | iPhone 6.7" ✓ · iPad 13" ✓ |
| Export compliance | `usesNonExemptEncryption: false` ✓ |
| Review notes | Updated from `distribution/AppStoreReviewReply-Jun05-2026.txt` ✓ |
| State | **WAITING_FOR_REVIEW** |
| GitHub commit | [`9554e9a`](https://github.com/chrsappiah-cloud/medlingo/commit/9554e9a) on `fix/iap-free-resubmission-docs` |
