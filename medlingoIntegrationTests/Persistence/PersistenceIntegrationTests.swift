import Foundation
import Testing
import SwiftData
@testable import medlingo

struct PersistenceIntegrationTests {
    @Test func modelContainer_inMemory_storesCachedChapter() throws {
        let schema = Schema([
            CachedChapter.self,
            CachedProgress.self,
            PendingSyncAction.self,
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])

        let chapter = Chapter(
            id: UUID(),
            number: 2,
            title: "Integration Stage",
            summary: "Test",
            estimatedMinutes: 40,
            isPremium: false,
            coverArtURL: nil,
            accentColorHex: "3498DB",
            prerequisiteIDs: [],
            unlockRule: .free
        )

        let context = ModelContext(container)
        context.insert(CachedChapter(from: chapter))
        try context.save()

        let descriptor = FetchDescriptor<CachedChapter>()
        let stored = try context.fetch(descriptor)
        #expect(stored.count == 1)
        #expect(stored[0].title == "Integration Stage")
    }

    @Test func sessionStore_userDefaults_roundTrip() {
        let suiteName = "medlingo.integration.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        let store = UserDefaultsSessionStore(defaults: defaults)

        store.saveRefreshToken("refresh-123")
        store.saveAccessToken("access-456")

        #expect(store.loadRefreshToken() == "refresh-123")
        #expect(store.loadAccessToken() == "access-456")

        store.clear()
        #expect(store.loadRefreshToken() == nil)
        defaults.removePersistentDomain(forName: suiteName)
    }
}
