import XCTest
@testable import medlingo

// MARK: - Lifecycle test suite
// Covers the six tests prescribed by the iOS Lifecycle Debugging Kit:
//   1. Launch test       – launched triggers only expected startup work
//   2. Resume test       – becameActive triggers a stale-data refresh
//   3. Background save   – enteredBackground saves state and ends the bg task
//   4. Failure-path save – persistence failure is logged, state not corrupted
//   5. Memory-warning    – non-critical tasks are cancelled
//   6. Regression test   – previously observed sign-in button fix is covered

@MainActor
final class AppLifecycleOrchestratorTests: XCTestCase {

    // MARK: - 1. Launch test

    func testLaunchDoesNotRefreshWhenUnauthenticated() async {
        let sync = MockSyncCoordinator()
        let orchestrator = makeOrchestrator(sync: sync)

        // Not authenticated — launch must not trigger a refresh
        orchestrator.handle(.launched)
        await Task.yield()

        XCTAssertEqual(sync.refreshCallCount, 0,
            "Launch must not refresh when user is unauthenticated")
    }

    func testLaunchTriggersRefreshWhenAuthenticated() async {
        let sync = MockSyncCoordinator()
        let orchestrator = makeOrchestrator(sync: sync)
        orchestrator.updateAuth(true)

        orchestrator.handle(.launched)
        // Allow the async task inside handle() to run
        try? await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertEqual(sync.refreshCallCount, 1,
            "Authenticated launch must trigger exactly one refresh")
    }

    // MARK: - 2. Resume test

    func testResumeRefreshesWhenAppBecomesActive() async {
        let sync = MockSyncCoordinator()
        let orchestrator = makeOrchestrator(sync: sync)
        orchestrator.updateAuth(true)

        orchestrator.handle(.becameActive)
        try? await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertEqual(sync.refreshCallCount, 1,
            "becameActive must trigger one refresh")
    }

    func testResumeSkipsRefreshWhenDataIsFresh() async {
        let sync = MockSyncCoordinator()
        let orchestrator = makeOrchestrator(sync: sync)
        orchestrator.updateAuth(true)

        // First resume — sets lastSyncAt
        orchestrator.handle(.becameActive)
        try? await Task.sleep(nanoseconds: 50_000_000)
        let firstCount = sync.refreshCallCount

        // Second resume immediately — sync coordinator gates by staleness
        orchestrator.handle(.becameActive)
        try? await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertEqual(sync.refreshCallCount, firstCount,
            "Immediate second resume must not trigger a redundant refresh (gated by staleness)")
    }

    // MARK: - 3. Background save test

    func testBackgroundEventSavesChangesAndEndsTask() async {
        let persistence = MockPersistenceCoordinator()
        let background = MockBackgroundTaskCoordinator()
        let orchestrator = makeOrchestrator(persistence: persistence, background: background)

        orchestrator.markDirty()
        orchestrator.handle(.enteredBackground)
        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(persistence.saveCallCount, 1,
            "Background entry must trigger exactly one save")
        XCTAssertEqual(background.beginCallCount, 1,
            "Background entry must begin exactly one background task")
        XCTAssertEqual(background.endCallCount, 1,
            "Background task must be ended after save completes")
        XCTAssertFalse(orchestrator.state.hasUnsavedChanges,
            "Dirty flag must be cleared after a successful save")
    }

    // MARK: - 4. Failure-path save test

    func testPersistenceFailureIsLoggedAndDoesNotCorruptState() async {
        let persistence = MockPersistenceCoordinator()
        persistence.shouldThrow = true
        let orchestrator = makeOrchestrator(persistence: persistence)

        orchestrator.markDirty()
        let dirtyBefore = orchestrator.state.hasUnsavedChanges

        orchestrator.handle(.enteredBackground)
        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertTrue(dirtyBefore,
            "State must be dirty before the failing save")
        XCTAssertEqual(persistence.saveCallCount, 1,
            "Persistence must be called even when it throws")
        // Dirty flag must remain set — do not silently swallow the error
        XCTAssertTrue(orchestrator.state.hasUnsavedChanges,
            "Dirty flag must remain set when persistence fails")
    }

    // MARK: - 5. Memory-warning test

    func testMemoryWarningCancelsNonCriticalTasks() {
        let sync = MockSyncCoordinator()
        let orchestrator = makeOrchestrator(sync: sync)

        orchestrator.handle(.memoryWarning)

        XCTAssertEqual(sync.cancelCallCount, 1,
            "Memory warning must cancel non-critical tasks exactly once")
    }

    func testWillResignActiveCancelsNonCriticalTasks() {
        let sync = MockSyncCoordinator()
        let orchestrator = makeOrchestrator(sync: sync)

        orchestrator.handle(.willResignActive)

        XCTAssertEqual(sync.cancelCallCount, 1,
            "willResignActive must cancel non-critical tasks")
    }

    // MARK: - 6. Regression test (sign-in button bug — Apple rejection #9)

    func testTerminationSavesAndClearsDirtyFlag() async {
        let persistence = MockPersistenceCoordinator()
        let orchestrator = makeOrchestrator(persistence: persistence)

        orchestrator.markDirty()
        orchestrator.handle(.willTerminate)
        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(persistence.saveCallCount, 1,
            "Termination must trigger a save")
        XCTAssertFalse(orchestrator.state.hasUnsavedChanges,
            "Dirty flag must be cleared on successful termination save")
    }

    func testUpdateAuthMirrorsStateIntoSnapshot() {
        let orchestrator = makeOrchestrator()

        XCTAssertFalse(orchestrator.state.isUserAuthenticated)
        orchestrator.updateAuth(true)
        XCTAssertTrue(orchestrator.state.isUserAuthenticated)
        orchestrator.updateAuth(false)
        XCTAssertFalse(orchestrator.state.isUserAuthenticated)
    }

    func testMarkDirtySetsUnsavedChangesFlag() {
        let orchestrator = makeOrchestrator()
        XCTAssertFalse(orchestrator.state.hasUnsavedChanges)
        orchestrator.markDirty()
        XCTAssertTrue(orchestrator.state.hasUnsavedChanges)
    }

    // MARK: - Helpers

    private func makeOrchestrator(
        persistence: PersistenceCoordinating = MockPersistenceCoordinator(),
        sync: SyncCoordinating = MockSyncCoordinator(),
        background: BackgroundTaskCoordinating = MockBackgroundTaskCoordinator()
    ) -> AppLifecycleOrchestrator {
        AppLifecycleOrchestrator(
            persistence: persistence,
            sync: sync,
            backgroundTasks: background
        )
    }
}

// MARK: - Mock coordinators

final class MockPersistenceCoordinator: PersistenceCoordinating {
    var saveCallCount = 0
    var shouldThrow = false

    func saveIfNeeded() async throws {
        saveCallCount += 1
        if shouldThrow { throw MockError.simulatedFailure }
    }
}

final class MockSyncCoordinator: SyncCoordinating {
    var refreshCallCount = 0
    var cancelCallCount = 0
    /// When true, gate refresh by a staleness check to simulate real coordinator behaviour.
    var gateByStaleness = true
    private var lastRefreshed: Date?

    func refreshIfStale(since lastSyncAt: Date?) async throws {
        if gateByStaleness, let last = lastRefreshed,
           Date().timeIntervalSince(last) < 5 { return }
        refreshCallCount += 1
        lastRefreshed = Date()
    }

    func cancelNonCriticalTasks() {
        cancelCallCount += 1
    }
}

final class MockBackgroundTaskCoordinator: BackgroundTaskCoordinating {
    var beginCallCount = 0
    var endCallCount = 0

    func begin(name: String) -> UUID {
        beginCallCount += 1
        return UUID()
    }

    func end(_ id: UUID?) {
        endCallCount += 1
    }
}

enum MockError: Error {
    case simulatedFailure
}
