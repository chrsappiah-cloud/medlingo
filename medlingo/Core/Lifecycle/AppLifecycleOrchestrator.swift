import Combine
import Foundation
import OSLog

/// Central lifecycle orchestrator — receives every `AppLifecycleEvent` and
/// dispatches to focused coordinators. All side effects live here; views stay
/// passive. Keeping this class isolated makes it fully unit-testable.
@MainActor
final class AppLifecycleOrchestrator: ObservableObject {

    // MARK: - Published state (observed by views via environmentObject if needed)

    @Published private(set) var state = AppStateSnapshot()

    // MARK: - Collaborators

    private let persistence: PersistenceCoordinating
    private let sync: SyncCoordinating
    private let backgroundTasks: BackgroundTaskCoordinating

    // MARK: - Logging

    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "wcs.medlingo",
        category: "app.lifecycle"
    )

    // MARK: - Init

    init(
        persistence: PersistenceCoordinating,
        sync: SyncCoordinating,
        backgroundTasks: BackgroundTaskCoordinating
    ) {
        self.persistence = persistence
        self.sync = sync
        self.backgroundTasks = backgroundTasks
    }

    // MARK: - Public API

    /// Route a lifecycle event to the appropriate handler.
    func handle(_ event: AppLifecycleEvent) {
        logger.info("Lifecycle event: \(event.description, privacy: .public)")
        RuntimeLogger.log(.lifecycle, "event=\(event.description)")

        switch event {
        case .launched:
            Task { await onLaunch() }

        case .becameActive:
            Task { await onBecomeActive() }

        case .willResignActive:
            sync.cancelNonCriticalTasks()
            logger.info("Non-critical tasks cancelled on resign-active")

        case .enteredBackground:
            Task { await onEnteredBackground() }

        case .willEnterForeground:
            logger.info("App will enter foreground")

        case .willTerminate:
            Task { await persistBeforeTermination() }

        case .memoryWarning:
            sync.cancelNonCriticalTasks()
            logger.warning("Memory warning received — non-critical tasks cancelled")
            RuntimeLogger.log(.lifecycle, "memoryWarning: non-critical tasks cancelled", level: .error)
        }
    }

    /// Mark that the user has unsaved changes that must survive backgrounding.
    func markDirty() {
        state.hasUnsavedChanges = true
    }

    /// Mirror authentication state into the snapshot so refresh decisions are auth-gated.
    func updateAuth(_ isAuthenticated: Bool) {
        state.isUserAuthenticated = isAuthenticated
        logger.info("Auth state updated: isAuthenticated=\(isAuthenticated, privacy: .public)")
    }

    // MARK: - Private handlers

    private func onLaunch() async {
        let start = Date()
        logger.info("Cold launch started")
        RuntimeLogger.log(.lifecycle, "cold-launch start")
        LaunchProfiler.end()

        if state.isUserAuthenticated {
            await refreshIfNeeded(reason: "launch")
        }

        let elapsed = Date().timeIntervalSince(start)
        logger.info("Cold launch complete in \(String(format: "%.2f", elapsed), privacy: .public)s")
        RuntimeLogger.log(.lifecycle, "cold-launch complete elapsed=\(String(format: "%.2f", elapsed))s")
    }

    private func onBecomeActive() async {
        logger.info("App became active")
        RuntimeLogger.log(.lifecycle, "becameActive")
        await refreshIfNeeded(reason: "resume")
    }

    private func onEnteredBackground() async {
        logger.info("App entered background — starting save-and-flush task")
        RuntimeLogger.log(.lifecycle, "enteredBackground start")

        let taskID = backgroundTasks.begin(name: "medlingo.save-and-flush")
        defer { backgroundTasks.end(taskID) }

        let start = Date()
        do {
            try await persistence.saveIfNeeded()
            state.hasUnsavedChanges = false
            let elapsed = Date().timeIntervalSince(start)
            logger.info("Background save succeeded in \(String(format: "%.2f", elapsed), privacy: .public)s")
            RuntimeLogger.log(.lifecycle, "background-save success elapsed=\(String(format: "%.2f", elapsed))s")
        } catch {
            logger.error("Background save failed: \(error.localizedDescription, privacy: .public)")
            RuntimeLogger.log(.lifecycle, "background-save failed: \(error.localizedDescription)", level: .error)
        }
    }

    private func persistBeforeTermination() async {
        logger.info("Termination save started")
        RuntimeLogger.log(.lifecycle, "willTerminate start")
        do {
            try await persistence.saveIfNeeded()
            state.hasUnsavedChanges = false
            logger.info("Termination save succeeded")
            RuntimeLogger.log(.lifecycle, "willTerminate save success")
        } catch {
            logger.error("Termination save failed: \(error.localizedDescription, privacy: .public)")
            RuntimeLogger.log(.lifecycle, "willTerminate save failed: \(error.localizedDescription)", level: .error)
        }
    }

    private func refreshIfNeeded(reason: String) async {
        do {
            try await sync.refreshIfStale(since: state.lastSyncAt)
            state.lastSyncAt = Date()
            logger.info("Refresh completed, reason: \(reason, privacy: .public)")
            RuntimeLogger.log(.lifecycle, "refresh complete reason=\(reason)")
        } catch {
            logger.error("Refresh failed, reason: \(reason, privacy: .public), error: \(error.localizedDescription, privacy: .public)")
            RuntimeLogger.log(.lifecycle, "refresh failed reason=\(reason) error=\(error.localizedDescription)", level: .error)
        }
    }
}
