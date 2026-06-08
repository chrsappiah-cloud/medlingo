import UIKit

/// Concrete background-task coordinator that wraps `UIApplication.beginBackgroundTask`.
/// Tracking task IDs prevents duplicate begins and ensures every begin has a matching end.
final class AppBackgroundTaskCoordinator: BackgroundTaskCoordinating {

    private var activeTasks: [UUID: UIBackgroundTaskIdentifier] = [:]

    func begin(name: String) -> UUID {
        let id = UUID()
        let taskID = UIApplication.shared.beginBackgroundTask(withName: name) { [weak self] in
            // Expiration handler — system is about to suspend us.
            RuntimeLogger.log(.lifecycle, "background task expired: \(name)", level: .error)
            self?.end(id)
        }
        activeTasks[id] = taskID
        RuntimeLogger.log(.lifecycle, "background task begun: \(name) id=\(id)")
        return id
    }

    func end(_ id: UUID?) {
        guard let id, let taskID = activeTasks.removeValue(forKey: id) else { return }
        UIApplication.shared.endBackgroundTask(taskID)
        RuntimeLogger.log(.lifecycle, "background task ended id=\(id)")
    }
}
