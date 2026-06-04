import Foundation
import SwiftData

/// Concrete persistence coordinator backed by SwiftData.
/// Saves pending sync actions and any dirty model context state.
/// Called only on background entry or termination — not on every data change.
final class AppPersistenceCoordinator: PersistenceCoordinating {

    private let modelContainer: ModelContainer

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    /// Save pending changes in the main context if any exist.
    /// This is a no-op if the context has no unsaved changes, keeping it idempotent.
    func saveIfNeeded() async throws {
        let context = await MainActor.run { modelContainer.mainContext }
        try await MainActor.run {
            if context.hasChanges {
                try context.save()
            }
        }
    }
}
