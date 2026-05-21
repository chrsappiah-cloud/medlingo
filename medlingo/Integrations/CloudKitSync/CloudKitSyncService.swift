import Foundation
import CloudKit

protocol CloudKitSyncProtocol {
    func syncProgress(chapters: [UUID: Double]) async throws
    func fetchCachedProgress() async throws -> [UUID: Double]
    func saveStudyState(lastChapterID: UUID, lastLessonID: UUID) async throws
    func fetchStudyState() async throws -> (chapterID: UUID, lessonID: UUID)?
}

final class CloudKitSyncService: CloudKitSyncProtocol {
    private let containerIdentifier: String
    private var _container: CKContainer?
    private var container: CKContainer {
        if let c = _container { return c }
        let c = CKContainer(identifier: containerIdentifier)
        _container = c
        return c
    }
    private var privateDB: CKDatabase { container.privateCloudDatabase }

    init(containerIdentifier: String = "iCloud.com.medlingo.app") {
        self.containerIdentifier = containerIdentifier
    }

    func syncProgress(chapters: [UUID: Double]) async throws {
        for (chapterID, progress) in chapters {
            let recordID = CKRecord.ID(recordName: "progress_\(chapterID.uuidString)")
            let record = CKRecord(recordType: "ChapterProgress", recordID: recordID)
            record["chapterID"] = chapterID.uuidString as CKRecordValue
            record["progress"] = progress as CKRecordValue
            record["syncedAt"] = Date() as CKRecordValue

            let operation = CKModifyRecordsOperation(recordsToSave: [record])
            operation.savePolicy = .changedKeys
            privateDB.add(operation)
        }
    }

    func fetchCachedProgress() async throws -> [UUID: Double] {
        let query = CKQuery(recordType: "ChapterProgress", predicate: NSPredicate(value: true))
        let results = try await privateDB.records(matching: query)

        var progressMap: [UUID: Double] = [:]
        for (_, result) in results.matchResults {
            if let record = try? result.get(),
               let idString = record["chapterID"] as? String,
               let id = UUID(uuidString: idString),
               let progress = record["progress"] as? Double {
                progressMap[id] = progress
            }
        }
        return progressMap
    }

    func saveStudyState(lastChapterID: UUID, lastLessonID: UUID) async throws {
        let recordID = CKRecord.ID(recordName: "study_state")
        let record = CKRecord(recordType: "StudyState", recordID: recordID)
        record["lastChapterID"] = lastChapterID.uuidString as CKRecordValue
        record["lastLessonID"] = lastLessonID.uuidString as CKRecordValue
        record["updatedAt"] = Date() as CKRecordValue

        try await privateDB.save(record)
    }

    func fetchStudyState() async throws -> (chapterID: UUID, lessonID: UUID)? {
        let recordID = CKRecord.ID(recordName: "study_state")
        do {
            let record = try await privateDB.record(for: recordID)
            guard let chapterIDStr = record["lastChapterID"] as? String,
                  let lessonIDStr = record["lastLessonID"] as? String,
                  let chapterID = UUID(uuidString: chapterIDStr),
                  let lessonID = UUID(uuidString: lessonIDStr) else {
                return nil
            }
            return (chapterID, lessonID)
        } catch {
            return nil
        }
    }
}
