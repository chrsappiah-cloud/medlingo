# ARC Shield Regression Ledger

Every App Review rejection and production defect becomes a durable test entry.

| ID | Date | Apple / defect reason | Root cause tag | Confirmation test | Regression tests | Verified build | Status |
|----|------|----------------------|----------------|-------------------|------------------|----------------|--------|
| R-001 | 2026-05-27 | Guideline 2.1(b) — purchase button error in prior build | `purchase-history` | *(removed — no purchase UI)* | `ReviewFlowTests.testAccount_signOutButtonReachable`, `AuthServiceTests`, `DataMiddlewareTests.isStageUnlocked_alwaysReturnsTrue` | 202606030900 | **Resolved — purchases removed** |
| R-002 | 2026-06-01 | Guideline 2.1(b) — purchase products not submitted for review in prior build | `purchase-history` | Account tab has no purchase section | `ReviewFlowTests`, `SmokeTests.testTabNavigation_criticalScreensOpen` | 202606030900 | **Resolved — purchases removed** |

## R-001 detail (historical)

- **Device / OS:** iPhone 17 Pro Max / iOS 26.5
- **Original issue:** Prior Account purchase flow showed errors or no feedback
- **Original root cause:** Prior build referenced purchase products that were not part of the submitted review package
- **Final resolution:** All purchase UI removed. App is fully free. No StoreKit integration.
- **Current confirmation:** Reviewers reach Account → profile, preferences, help, sign-out only. No upgrade, restore, plan, or paywall screens.
- **Regression:** UI smoke + account sign-out test; all stages unlocked in unit tests

## R-002 detail

- **Issue:** Prior build referenced paid plans but products were not submitted in App Store Connect
- **Resolution:** Removed all purchase code, models, and UI. Do not attach purchase products to resubmission builds.
- **Regression:** No purchase strings in Swift codebase; App Store version should be submitted without purchase products

## Template for new entries

```markdown
| R-00N | YYYY-MM-DD | Reason | `tag` | `TestClass.testName` | related tests | build | Open/Resolved |
```

### Root cause tags

`launch` · `permission` · `auth` · `network` · `stateRestoration` · `migration` · `uiFreeze` · `crash`

> **Note:** Use tag `purchase-history` only for historical entries. Medlingo no longer ships In-App Purchases.
