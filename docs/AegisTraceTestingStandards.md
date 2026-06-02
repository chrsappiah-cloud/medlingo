# WCS AegisTrace Testing Standards

WCS AegisTrace turns testing into a release chain: specify, observe, attack the weak point, prove, fix, and memorialize.

## Modules

- AegisTraceKit: assertion helpers, fixture loading, deterministic clocks, UUID injection, mock network clients.
- AegisTraceLogger: structured events for screen transitions, state mutations, API calls, retries, decoding failures, thread hops, and scenarios.
- AegisTraceMatrix: JSON traceability manifest mapping feature, risk, tests, defects, and release status.
- AegisTraceLab: local scenario runner with seeded accounts, offline mode, time travel, and hostile payload labels.
- AegisTraceReports: markdown release reports with coverage summary, open risks, lab scenarios, and acceptance status.

## Test Layers

- Contract: pure Swift domain logic, learning-state logic, entitlement checks, and ranking algorithms.
- Flow: coordinators, reducers, view models, async fetch, retry, pause/resume, and partial failure state.
- Boundary: API clients, persistence, decoding, caching, and permission gates with mocks/fakes.
- Risk: defect clusters, high-value paths, concurrency, stale cache, race conditions, and poor-network behavior.
- Acceptance: top WCS journeys such as onboarding, sign-in, lesson consumption, uploads, and teacher/admin workflows.

## MedLingo Integration

- Test support lives in `medlingoTests/Support/AegisTraceSupport.swift`.
- Standards enforcement lives in `medlingoTests/Contract/AegisTraceStandardsTests.swift`.
- The traceability manifest lives in `config/aegis-trace-matrix.json`.
- Release summaries can be generated through `AegisTraceReports.markdown(...)`.

Tagline: WCS AegisTrace — trace every requirement, reproduce every failure, harden every release.
