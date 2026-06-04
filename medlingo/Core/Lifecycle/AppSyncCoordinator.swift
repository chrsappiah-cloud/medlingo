import Foundation

/// Concrete sync coordinator backed by `DataMiddleware`.
/// Refreshes data only when it is stale (>5 min since last sync) or never loaded.
/// Cancelling non-critical tasks is a no-op today but the hook is wired for future work.
@MainActor
final class AppSyncCoordinator: SyncCoordinating {

    private let middleware: DataMiddleware
    /// Minimum age of cached data before a refresh is triggered.
    private let stalenessThreshold: TimeInterval

    init(
        middleware: DataMiddleware = .shared,
        stalenessThreshold: TimeInterval = 5 * 60
    ) {
        self.middleware = middleware
        self.stalenessThreshold = stalenessThreshold
    }

    func refreshIfStale(since lastSyncAt: Date?) async throws {
        guard isStale(lastSyncAt) else {
            RuntimeLogger.log(.lifecycle, "sync skipped — data is fresh")
            return
        }
        RuntimeLogger.log(.lifecycle, "sync triggered — data is stale")
        await middleware.loadInitialData()
    }

    func cancelNonCriticalTasks() {
        // DataMiddleware tasks are short-lived; cancellation is surfaced via
        // the middleware's `isLoading` flag. Future background tasks should
        // store their `Task` handles here for explicit cancellation.
        RuntimeLogger.log(.lifecycle, "cancelNonCriticalTasks called")
    }

    // MARK: - Private

    private func isStale(_ lastSyncAt: Date?) -> Bool {
        guard let date = lastSyncAt else { return true }
        return Date().timeIntervalSince(date) > stalenessThreshold
    }
}
