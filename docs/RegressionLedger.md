# ARC Shield Regression Ledger

Every App Review rejection and production defect becomes a durable test entry.

| ID | Date | Apple / defect reason | Root cause tag | Confirmation test | Regression tests | Verified build | Status |
|----|------|----------------------|----------------|-------------------|------------------|----------------|--------|
| R-001 | 2026-05-27 | Guideline 2.1(b) — Upgrade button error on subscription screen | `purchase` | *(removed — no purchase UI)* | `ReviewFlowTests.testAccount_signOutButtonReachable`, `AuthServiceTests`, `DataMiddlewareTests.isStageUnlocked_alwaysReturnsTrue` | 202605301200 | **Resolved — IAP removed** |
| R-002 | 2026-05-30 | Guideline 2.1(b) — IAP products not submitted for review | `purchase` | Account tab has no subscription section | `ReviewFlowTests`, `SmokeTests.testTabNavigation_criticalScreensOpen` | 202605301200 | **Resolved — IAP removed** |

## R-001 detail (historical)

- **Device / OS:** iPhone 17 Pro Max / iOS 26.5
- **Original issue:** Account → Premium Plan → Upgrade showed errors or no feedback
- **Original root cause:** Silent `try?` on product load and purchase; empty product list; no loading or error UI
- **Final resolution:** All In-App Purchase and subscription UI removed. App is fully free. No StoreKit integration.
- **Current confirmation:** Reviewers reach Account → profile, preferences, help, sign-out only. No Upgrade, Restore, or Premium Plan screens.
- **Regression:** UI smoke + account sign-out test; all stages unlocked in unit tests

## R-002 detail

- **Issue:** App referenced premium plans but IAP products were not submitted in App Store Connect
- **Resolution:** Removed all IAP code, models, and UI. Do not attach IAP products to resubmission builds.
- **Regression:** No subscription strings in Swift codebase; `config/app_store_connect.json` products empty

## Template for new entries

```markdown
| R-00N | YYYY-MM-DD | Reason | `tag` | `TestClass.testName` | related tests | build | Open/Resolved |
```

### Root cause tags

`launch` · `permission` · `auth` · `network` · `stateRestoration` · `migration` · `uiFreeze` · `crash`

> **Note:** Use tag `purchase` only for historical entries. Medlingo no longer ships In-App Purchases.
