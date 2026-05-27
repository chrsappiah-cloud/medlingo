# ARC Shield Regression Ledger

Every App Review rejection and production defect becomes a durable test entry.

| ID | Date | Apple / defect reason | Root cause tag | Confirmation test | Regression tests | Verified build |
|----|------|----------------------|----------------|-------------------|------------------|----------------|
| R-001 | 2026-05-27 | Guideline 2.1(a) — Upgrade button not responding | `purchase` | `ReviewFlowTests.testSubscriptionPath_upgradeControlExists` | `SubscriptionStateTests.storeKit_loadProducts_whenProductsFailure_throws`, `AuthServiceTests` (session persistence) | 202605271300 |

## R-001 detail

- **Device / OS:** iPhone 17 Pro Max / iOS 26.5
- **Account state:** Premium UI, yearly upgrade available
- **Network:** Online (StoreKit sandbox)
- **Reproduction:** Account → Premium Plan → Upgrade on yearly plan → no feedback
- **Root cause:** Silent `try?` on product load and purchase; empty `availableProducts`; no loading or error UI
- **Fix:** `SubscriptionView` loading and error states; `StoreError.productNotFound`; non-blocking server verification
- **Confirmation:** UI test verifies Upgrade control on subscription path
- **Regression:** Unit tests for StoreKit mock failure and auth session persistence

## Template for new entries

```markdown
| R-00N | YYYY-MM-DD | Reason | `tag` | `TestClass.testName` | related tests | build |
```

### Root cause tags

`launch` · `permission` · `auth` · `network` · `purchase` · `stateRestoration` · `migration` · `uiFreeze` · `crash`
