# WCS Testing Kit — Medlingo

Concepts, tools, and workflows for product quality at **World Class Scholars**.

This kit turns TDD ideas into a practical testing stack for Medlingo: fast feedback, clean boundaries, safer refactors, and production-ready habits. It complements the **ARC Shield** runtime probes, regression ledger, and CI lanes already in this repo.

| | |
|---|---|
| **Core testing domains** | 6 |
| **Concepts to apply** | 18+ |
| **Tools & patterns in repo** | Swift Testing, XCTest, mocks, fakes, spies, JSON fixtures |

---

## What this kit covers

- **TDD cycle** — Red, Green, Refactor for product features
- **Test architecture** — Suite structure, naming, assertions, expectations
- **Isolation strategies** — Dependency injection, mocks, fakes, protocol boundaries
- **Scale-up tactics** — Networking, persistence, async UI, legacy refactoring paths

### Foundations

Use TDD to translate requirements into executable examples before implementation. Keep each change small, prove behavior first, and refactor only after tests are green.

- Red-Green-Refactor
- Behavior focus
- Regression safety
- Refactoring confidence

**Practices**

- Test externally visible behavior, not every line
- Prefer narrow, fast tests that isolate one rule
- Use TDD heavily for new features and risky code paths (auth, sync, review flows)

**Core tools**

- **Swift Testing** (`@Test`, `#expect`) for unit and integration tests
- **XCTest** for UI tests and launch tests
- Xcode test navigator, coverage, and breakpoints
- `@testable import medlingo` for internal app access
- Protocols plus dependency injection for replaceable services

---

## Unit tests

Structure tests with clear names, stable fixtures, and direct assertions. Validate initial state, mutations, derived outputs, and edge cases in isolation.

| Pattern | Location |
|---------|----------|
| Arrange-Act-Assert | `medlingoTests/Unit/*` |
| Shared fixtures | `medlingoTests/TestingSupport/Fixtures/TestDataFactory.swift` |
| JSON fixtures | `medlingoTests/TestingSupport/Fixtures/JSON/` |

**Practices**

- Use descriptive test names like `sampleChapters_allChaptersAreFree`
- Keep shared setup in type `init()` or helpers, but make each test readable on its own
- Track code coverage as a signal, not a goal
- Debug tests with breakpoints and repeatable fixtures

**Medlingo domain examples**

| Domain | What to test |
|--------|----------------|
| Stages & chapters | `Chapter` model, unlock rules, sample data, list/detail view models |
| Progress | Attempt scoring, completion percentages, persistence round-trips |
| Auth | Session persistence, expired token recovery, sign-out |
| Formatting | Status labels, stage numbering, progress display |

---

## Async & UI behavior

Use expectations when work crosses queues, uses notifications, or updates the UI after callbacks. Verify outcomes and timing, not just that a method was invoked.

**Medlingo examples**

| Flow | Tests |
|------|-------|
| Login / session | `AuthServiceTests`, `RecoveryTests` (`-seedExpiredToken`) |
| Learning events | `DataMiddlewareTests`, progress submission, analytics spies |
| Offline launch | `ReviewFlowTests.testOfflineLaunch_appRemainsNavigable` |
| Account | `ReviewFlowTests.testAccount_signOutButtonReachable` — no purchase UI |

**Launch arguments** (see `AppLaunchConfiguration.swift`, `UITestLaunchArguments.swift`)

- `-UITesting` / `-uiTestMode`
- `-mockNetworkOffline`
- `-seedExpiredToken`
- `-seedCreatorRole`
- `-mockAIGeneration`

---

## Mocks & dependency injection

Replace device APIs, services, time, and network layers with test doubles so behavior becomes deterministic. Inject dependencies explicitly instead of reaching for globals.

| Double | Use for |
|--------|---------|
| **Protocols** | Service boundaries (`ChapterServiceProtocol`, `AuthService`, etc.) |
| **Mocks** | Interaction verification (`ChapterServiceMock`, `SessionServiceMock`) |
| **Fakes** | Lightweight functional replacements (`KeyValueStoreFake`) |
| **Spies** | Analytics and navigation (`AnalyticsTrackerSpy`, `NavigatorSpy`) |
| **Stubs** | Controlled return values and error paths (`MockNetworkClient`) |

### Recommended Medlingo seams

| Service | Responsibility |
|---------|------------------|
| `AuthService` | Login, refresh, role checks, sign-out |
| `ChapterService` / `DataMiddleware` | Catalog, lessons, exercises, stage unlock |
| `ProgressService` | Attempt submission, mastery recompute |
| `SessionService` | Tutor sessions, bookings, room tokens |
| `MessagingService` | Tutor chat |
| `AnalyticsService` | Event tracking |
| `InVideoAIService` | AI generation (demo mode via launch flags) |
| `CollectionStore` | Generated artwork gallery |
| `SyncCoordinator` / `CloudKitSyncService` | Offline sync |
| `PermissionProvider` | Microphone/camera policy for sessions |

> **Note:** Medlingo is a **free app** with no In-App Purchases. Do not add `PurchaseService`, StoreKit mocks, or subscription-state fixtures. All stages are unlocked; test access rules accordingly.

---

## Networking & media

Test API clients in slices: request creation, HTTP status handling, decoding success, decoding failure, and dispatch back to a response queue.

| Pattern | Location |
|---------|----------|
| Mock URLSession | `MockURLProtocol`, `NetworkClientBehaviorTests` |
| Contract tests | `medlingoTests/Contract/NetworkContractTests.swift` |
| JSON decode | `medlingoTests.swift` — `ChapterModelTests`, `LessonModelTests` |

**Practices**

- Avoid real network calls in unit tests
- Test invalid payloads as carefully as valid payloads
- Cache and cancel stale media requests where cells reuse artwork

**Medlingo client examples**

| Client | Scenarios |
|--------|-----------|
| Chapter feed | Catalog fetch, fallback sample data when offline |
| Lesson content | Lessons per chapter, exercise lists |
| Artwork / AI | Demo generation, quota errors, progress callbacks |

---

## Legacy refactoring

When code already exists, start with characterization tests, map dependencies, and break coupling one seam at a time.

1. Write tests that preserve current behavior first
2. Create dependency maps to find direct and indirect coupling
3. Extract modules and protocols gradually, not in one rewrite

### Medlingo migration path

1. Map views that directly hit Supabase/network code
2. Pull data access into `DataMiddleware` and protocol-backed services
3. Replace singleton-heavy flows with injected dependencies (see `DataMiddleware` init, `AppState` bootstrap)
4. Add analytics through `AnalyticsServiceProtocol` rather than inline calls
5. Move shared business logic into testable modules under `Core/` and `SharedModels/`

---

## WCS toolkit blueprint (Medlingo)

| Layer | Implementation |
|-------|----------------|
| **Frameworks** | Swift Testing (unit/integration), XCTest (UI), XCUITest smoke + review flows |
| **Patterns** | Protocol-first services, repository-style middleware, factory fixtures, launch-configuration fakes |
| **Test suites** | `medlingoTests` (unit + contract), `medlingoIntegrationTests`, `medlingoUITests` |
| **Fixture assets** | JSON response files, `TestDataFactory`, sample chapters/sessions/users |
| **CI gates** | `.github/workflows/ci.yml` — unit on every PR; integration + UI on `main` |

### Directory map

```
medlingoTests/
├── Unit/                    # Domain, services, view models
├── Contract/                # API shape contracts
├── TestingSupport/
│   ├── Fixtures/            # TestDataFactory, JSON/
│   ├── Mocks/               # Service mocks, MockURLProtocol
│   ├── Fakes/               # KeyValueStoreFake
│   └── Spies/               # Analytics, navigation
medlingoIntegrationTests/    # SwiftData persistence, cross-module
medlingoUITests/
├── Smoke/                   # Tab navigation, critical content
├── ReviewFlows/             # App Review paths (offline, account)
├── Recovery/                # Expired token, error recovery
└── Support/                 # Launch args, base test case
medlingo/Core/Testing/       # AppLaunchConfiguration, RuntimeLogger, AppBootstrapper
```

---

## Definition of done

| Phase | Requirement |
|-------|-------------|
| **Before coding** | At least one failing test for the new rule |
| **During coding** | Smallest change that turns red to green |
| **After green** | Refactor naming, duplication, and seams without changing behavior |
| **Before merge** | Verify async, error, empty, and loading states |
| **App Review changes** | Add entry to `docs/RegressionLedger.md` with confirmation + regression tests |

---

## ARC Shield integration

Every App Review rejection or production defect should become a durable test entry in [`RegressionLedger.md`](RegressionLedger.md).

| Component | Purpose |
|-----------|---------|
| `RuntimeLogger` | Structured launch/auth/network logging |
| `AppLaunchConfiguration` | Deterministic UI test scenarios |
| `ReviewFlowTests` | Reviewer-critical paths without sign-in or IAP |
| CI workflows | `ci.yml`, `ci-release.yml` |

Run locally:

```bash
# Unit tests
xcodebuild test -project medlingo.xcodeproj -scheme medlingo \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
  -only-testing:medlingoTests

# UI smoke
xcodebuild test -project medlingo.xcodeproj -scheme medlingo \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
  -only-testing:medlingoUITests/SmokeTests
```

---

Built as a lightweight internal reference for World Class Scholars product and engineering work — especially iOS modules, service boundaries, and Medlingo feature delivery.
