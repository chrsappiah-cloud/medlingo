import Foundation

// MARK: - PersistenceCoordinating

/// Saves critical user-generated state. Called on background entry and termination.
protocol PersistenceCoordinating {
    /// Persist only if there are unsaved changes. Must be fast and bounded.
    func saveIfNeeded() async throws
}

// MARK: - SyncCoordinating

/// Refreshes remote data and cancels non-critical in-flight work.
protocol SyncCoordinating {
    /// Fetch fresh data only when `lastSyncAt` is stale or nil.
    func refreshIfStale(since lastSyncAt: Date?) async throws
    /// Cancel low-priority tasks when the app resigns active or gets a memory warning.
    func cancelNonCriticalTasks()
}

// MARK: - BackgroundTaskCoordinating

/// Wraps UIApplication background-task identifiers so saves survive suspension.
protocol BackgroundTaskCoordinating {
    /// Acquire a background-task assertion. Returns a UUID tracking the task.
    func begin(name: String) -> UUID
    /// Release a previously acquired background-task assertion.
    func end(_ id: UUID?)
}
