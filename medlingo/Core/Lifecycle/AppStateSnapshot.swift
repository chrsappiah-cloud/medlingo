import Foundation

/// Lightweight snapshot of app state that the orchestrator needs to make
/// lifecycle decisions (refresh gating, dirty-flag persistence, auth checks).
struct AppStateSnapshot: Equatable {
    var lastSyncAt: Date?
    var hasUnsavedChanges: Bool = false
    var activeTaskCount: Int = 0
    var isUserAuthenticated: Bool = false
}
