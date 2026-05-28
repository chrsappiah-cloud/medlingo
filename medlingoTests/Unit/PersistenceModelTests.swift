import Testing
import Foundation
import SwiftData
@testable import medlingo

@MainActor
struct PersistenceModelTests {
    var container: ModelContainer
    var context: ModelContext

    init() throws {
        let schema = Schema([CachedChapter.self, CachedProgress.self, PendingSyncAction.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: [config])
        context = ModelContext(container)
    }

    // MARK: - CachedChapter

    @Test func cachedChapter_initFromChapter() {
        let chapter = Chapter(id: UUID(), number: 3, title: "Skeletal", summary: "Bones", estimatedMinutes: 75, isPremium: false, coverArtURL: nil, accentColorHex: "50C878", prerequisiteIDs: [], unlockRule: .free)
        let cached = CachedChapter(from: chapter)

        #expect(cached.chapterID == chapter.id)
        #expect(cached.number == 3)
        #expect(cached.title == "Skeletal")
        #expect(cached.summary == "Bones")
        #expect(cached.estimatedMinutes == 75)
        #expect(cached.isPremium == false)
        #expect(cached.accentColorHex == "50C878")
    }

    @Test func cachedChapter_setsLastSyncedAt() {
        let before = Date()
        let cached = CachedChapter(from: Chapter(id: UUID(), number: 1, title: "Test", summary: "", estimatedMinutes: 10, isPremium: false, coverArtURL: nil, accentColorHex: "", prerequisiteIDs: [], unlockRule: .free))

        #expect(cached.lastSyncedAt >= before)
    }

    @Test func cachedChapter_roundTrip() throws {
        let chapter = Chapter(id: UUID(), number: 5, title: "Nervous", summary: "Nerves", estimatedMinutes: 90, isPremium: false, coverArtURL: nil, accentColorHex: "", prerequisiteIDs: [], unlockRule: .free)
        let cached = CachedChapter(from: chapter)
        context.insert(cached)
        try context.save()

        let descriptor = FetchDescriptor<CachedChapter>(predicate: #Predicate { $0.chapterID == chapter.id })
        let fetched = try context.fetch(descriptor)

        #expect(fetched.count == 1)
        #expect(fetched.first?.title == "Nervous")
        #expect(fetched.first?.number == 5)
    }

    @Test func cachedChapter_insertAndUpdateSameID() throws {
        let id = UUID()
        let chapter1 = Chapter(id: id, number: 1, title: "First", summary: "", estimatedMinutes: 10, isPremium: false, coverArtURL: nil, accentColorHex: "", prerequisiteIDs: [], unlockRule: .free)

        let cached = CachedChapter(from: chapter1)
        context.insert(cached)
        try context.save()

        cached.title = "Updated"
        try context.save()

        let descriptor = FetchDescriptor<CachedChapter>()
        let all = try context.fetch(descriptor)
        #expect(all.count == 1)
        #expect(all.first?.title == "Updated")
    }

    // MARK: - CachedProgress

    @Test func cachedProgress_init_setsDefaults() {
        let chapterID = UUID()
        let userID = UUID()
        let progress = CachedProgress(chapterID: chapterID, userID: userID)

        #expect(progress.chapterID == chapterID)
        #expect(progress.userID == userID)
        #expect(progress.lessonsCompleted == 0)
        #expect(progress.totalLessons == 0)
        #expect(progress.masteryScore == 0)
    }

    @Test func cachedProgress_completionPercentage_whenNoLessons_returnsZero() {
        let progress = CachedProgress(chapterID: UUID(), userID: UUID())
        #expect(progress.completionPercentage == 0)
    }

    @Test func cachedProgress_completionPercentage_calculatesCorrectly() {
        let progress = CachedProgress(chapterID: UUID(), userID: UUID())
        progress.totalLessons = 10
        progress.lessonsCompleted = 7

        #expect(progress.completionPercentage == 0.7)
    }

    @Test func cachedProgress_completionPercentage_fullProgress() {
        let progress = CachedProgress(chapterID: UUID(), userID: UUID())
        progress.totalLessons = 5
        progress.lessonsCompleted = 5

        #expect(progress.completionPercentage == 1.0)
    }

    @Test func cachedProgress_roundTrip() throws {
        let chapterID = UUID()
        let userID = UUID()
        let progress = CachedProgress(chapterID: chapterID, userID: userID)
        progress.masteryScore = 0.85
        context.insert(progress)
        try context.save()

        let descriptor = FetchDescriptor<CachedProgress>(predicate: #Predicate { $0.chapterID == chapterID })
        let fetched = try context.fetch(descriptor)

        #expect(fetched.count == 1)
        #expect(fetched.first?.masteryScore == 0.85)
        #expect(fetched.first?.userID == userID)
    }

    // MARK: - PendingSyncAction

    @Test func pendingSyncAction_init_setsDefaults() {
        let payload = "test".data(using: .utf8)!
        let action = PendingSyncAction(actionType: "ProgressUpdate", payload: payload)

        #expect(action.actionType == "ProgressUpdate")
        #expect(action.payload == payload)
        #expect(action.retryCount == 0)
        #expect(action.createdAt <= Date())
    }

    @Test func pendingSyncAction_retryCount_startsAtZero() {
        let action = PendingSyncAction(actionType: "Test", payload: Data())
        #expect(action.retryCount == 0)
    }

    @Test func pendingSyncAction_roundTrip() throws {
        let payload = "{\"key\":\"value\"}".data(using: .utf8)!
        let action = PendingSyncAction(actionType: "BookmarkSync", payload: payload)
        context.insert(action)
        try context.save()

        let descriptor = FetchDescriptor<PendingSyncAction>()
        let fetched = try context.fetch(descriptor)

        #expect(fetched.count == 1)
        #expect(fetched.first?.actionType == "BookmarkSync")
        #expect(fetched.first?.payload == payload)
    }
}
