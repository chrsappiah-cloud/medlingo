import Testing
import Foundation
import SwiftData
@testable import medlingo

@MainActor
struct SyncCoordinatorTests {
    var container: ModelContainer
    var context: ModelContext
    var sut: SyncCoordinator

    init() throws {
        let schema = Schema([PendingSyncAction.self, CachedProgress.self, CachedChapter.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: [config])
        context = ModelContext(container)
        sut = SyncCoordinator()
    }

    @Test func initialSyncState_isIdle() {
        #expect(sut.syncState == .idle)
    }

    @Test func initialPendingSyncCount_isZero() {
        #expect(sut.pendingSyncCount == 0)
    }

    @Test func initialLastSyncDate_isNil() {
        #expect(sut.lastSyncDate == nil)
    }

    @Test func queueAction_incrementsPendingCount() {
        sut.queueAction(actionType: "ProgressUpdate", payload: Data(), modelContext: context)

        #expect(sut.pendingSyncCount == 1)
    }

    @Test func queueAction_multipleActions_incrementsCount() {
        sut.queueAction(actionType: "ProgressUpdate", payload: Data(), modelContext: context)
        sut.queueAction(actionType: "ProgressUpdate", payload: Data(), modelContext: context)
        sut.queueAction(actionType: "Bookmark", payload: Data(), modelContext: context)

        #expect(sut.pendingSyncCount == 3)
    }

    @Test func queueAction_insertsIntoModelContext() {
        sut.queueAction(actionType: "ProgressUpdate", payload: Data(), modelContext: context)

        let descriptor = FetchDescriptor<PendingSyncAction>()
        let count = try? context.fetch(descriptor).count
        #expect(count == 1)
    }

    @Test func queueAction_storesCorrectType() {
        sut.queueAction(actionType: "LessonComplete", payload: Data(), modelContext: context)

        let descriptor = FetchDescriptor<PendingSyncAction>()
        let actions = try? context.fetch(descriptor)
        #expect(actions?.first?.actionType == "LessonComplete")
    }

    @Test func pushPendingActions_whenNone_doesNothing() async throws {
        try await sut.pushPendingActions(modelContext: context)

        #expect(sut.pendingSyncCount == 0)
    }

    @Test func queueAction_afterQueue_pendingCountMatches() async {
        sut.queueAction(actionType: "ProgressUpdate", payload: Data(), modelContext: context)

        #expect(sut.pendingSyncCount == 1)
    }
}
