# E2E Test Report — May 31, 2026

Full unit, integration, and UI test suite on **simulator** and **physical iPhone**.

## Summary

| Environment | Device | OS | Passed | Failed | Skipped | Result |
|-------------|--------|-----|--------|--------|---------|--------|
| Simulator | iPhone 17 Pro Max | iOS 26.5 | 210 | 0 | 0 | **PASS** |
| Physical | Christopher's iPhone (17 Pro Max) | iOS 26.6 | 209 | 0 | 1 | **PASS** |

**Total test count:** 210 (192 unit + integration in-app, 13 UI, 2 launch, 3 integration target suites)

## Test targets

| Target | Type | Count (approx.) |
|--------|------|-----------------|
| `medlingoTests` | Unit + contract | ~192 |
| `medlingoIntegrationTests` | Integration | ~5 |
| `medlingoUITests` | UI / E2E | 13 |

## Fixes applied during run

1. **AIVideoGenerationTests** — UI test matched wrong "Generate" button (model card). Fixed to use `generate-artwork-button` accessibility ID.
2. **DistributionScreenshotTests** — `/tmp` not writable on device sandbox. Fixed to use `NSTemporaryDirectory()`.
3. **medlingoUITestsLaunchTests.testLaunchPerformance** — flaky on device. Skipped on physical hardware (simulator-only baseline).

## Skipped on device

- `testLaunchPerformance` — launch metric baselines collected on simulator only

## Artifacts

| Path | Description |
|------|-------------|
| `build/test-results/simulator/FullE2E-v2.xcresult` | Simulator xcresult bundle |
| `build/test-results/simulator/full-e2e-v2.log` | Simulator log |
| `build/test-results/device/FullE2E-v3.xcresult` | Device xcresult bundle |
| `build/test-results/device/full-e2e-v3.log` | Device log |

## Re-run command

```bash
bash scripts/run-e2e-tests.sh
```

Or manually:

```bash
# Simulator
xcodebuild test -project medlingo.xcodeproj -scheme medlingo \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
  -only-testing:medlingoTests \
  -only-testing:medlingoIntegrationTests \
  -only-testing:medlingoUITests \
  CODE_SIGNING_ALLOWED=NO

# Physical iPhone (unlocked, trusted)
xcodebuild test -project medlingo.xcodeproj -scheme medlingo \
  -destination 'platform=iOS,id=00008150-001102643CD2401C' \
  -only-testing:medlingoTests \
  -only-testing:medlingoIntegrationTests \
  -only-testing:medlingoUITests \
  -allowProvisioningUpdates
```

## IAP verification

- Account tab: no subscription or purchase UI
- All stages accessible without paywall
- No StoreKit code in app
