import Foundation
import CloudKit
import SwiftData

@MainActor
@Observable
final class SyncCoordinator {
    static let shared = SyncCoordinator()

    private let container: CKContainer
    private let privateDB: CKDatabase

    private(set) var syncState: SyncState = .idle
    private(set) var lastSyncDate: Date?
    private(set) var pendingSyncCount = 0

    enum SyncState: String {
        case idle, syncing, error, offline
    }

    private init() {
        self.container = CKContainer(identifier: Config.cloudKitContainerID)
        self.privateDB = container.privateCloudDatabase
    }

    // MARK: - Full Sync

    func performFullSync(modelContext: ModelContext) async {
        syncState = .syncing

        do {
            try await pushPendingActions(modelContext: modelContext)
            try await pullRemoteChanges(modelContext: modelContext)
            lastSyncDate = Date()
            syncState = .idle
            pendingSyncCount = 0
        } catch {
            if isOfflineError(error) {
                syncState = .offline
            } else {
                syncState = .error
                print("SyncCoordinator: Full sync failed: \(error)")
            }
        }
    }

    // MARK: - Push Local Changes

    func pushPendingActions(modelContext: ModelContext) async throws {
        let descriptor = FetchDescriptor<PendingSyncAction>(
            sortBy: [SortDescriptor(\.createdAt)]
        )
        let pendingActions = try modelContext.fetch(descriptor)
        pendingSyncCount = pendingActions.count

        for action in pendingActions {
            try await pushSingleAction(action)
            modelContext.delete(action)
        }
        try modelContext.save()
    }

    private func pushSingleAction(_ action: PendingSyncAction) async throws {
        let record = CKRecord(recordType: action.actionType)
        record["payload"] = action.payload as CKRecordValue
        record["createdAt"] = action.createdAt as CKRecordValue
        try await privateDB.save(record)
    }

    // MARK: - Pull Remote Changes

    func pullRemoteChanges(modelContext: ModelContext) async throws {
        let progressRecords = try await fetchRecords(ofType: "ChapterProgress")
        for record in progressRecords {
            updateLocalProgress(from: record, modelContext: modelContext)
        }
        try modelContext.save()
    }

    private func fetchRecords(ofType recordType: String) async throws -> [CKRecord] {
        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
        let (results, _) = try await privateDB.records(matching: query)
        return results.compactMap { try? $0.1.get() }
    }

    // MARK: - Local Updates

    private func updateLocalProgress(from record: CKRecord, modelContext: ModelContext) {
        guard let chapterIDStr = record["chapterID"] as? String,
              let chapterID = UUID(uuidString: chapterIDStr),
              let mastery = record["masteryScore"] as? Double else { return }

        let descriptor = FetchDescriptor<CachedProgress>(
            predicate: #Predicate { $0.chapterID == chapterID }
        )

        if let existing = try? modelContext.fetch(descriptor).first {
            existing.masteryScore = mastery
            existing.lastStudiedAt = Date()
        } else {
            let progress = CachedProgress(chapterID: chapterID, userID: UUID())
            progress.masteryScore = mastery
            modelContext.insert(progress)
        }
    }

    // MARK: - Queue Local Action for Sync

    func queueAction(actionType: String, payload: Data, modelContext: ModelContext) {
        let action = PendingSyncAction(actionType: actionType, payload: payload)
        modelContext.insert(action)
        pendingSyncCount += 1
    }

    // MARK: - Helpers

    private func isOfflineError(_ error: Error) -> Bool {
        let nsError = error as NSError
        return nsError.domain == CKErrorDomain &&
            (nsError.code == CKError.networkUnavailable.rawValue ||
             nsError.code == CKError.networkFailure.rawValue)
    }
}
