import Testing
import Foundation
@testable import medlingo

@MainActor
struct ChapterServiceTests {
    var mockClient: MockNetworkClient
    var sut: ChapterService

    init() {
        mockClient = MockNetworkClient()
        sut = ChapterService(client: mockClient)
    }

    @Test func fetchChapters_usesCorrectPath() async throws {
        let expected = DataMiddleware.sampleChapters()
        let data = try JSONEncoder().encode(expected)
        mockClient.requestHandler = { _ in data }

        let chapters = try await sut.fetchChapters()

        #expect(chapters.count == expected.count)
        #expect(mockClient.lastEndpoint?.path == "chapters")
        #expect(mockClient.lastEndpoint?.method == .get)
    }

    @Test func fetchChapters_includesOrderQuery() async throws {
        mockClient.requestHandler = { _ in Data() }
        _ = try? await sut.fetchChapters()

        #expect(mockClient.lastEndpoint?.queryItems?.contains(where: { $0.name == "order" }) == true)
    }

    @Test func fetchLessons_usesChapterIDQuery() async throws {
        let chapterID = UUID()
        let expected = DataMiddleware.sampleLessons(for: chapterID)
        let data = try JSONEncoder().encode(expected)
        mockClient.requestHandler = { _ in data }

        let lessons = try await sut.fetchLessons(for: chapterID)

        #expect(lessons.count == 6)
        #expect(mockClient.lastEndpoint?.path == "lessons")
        #expect(mockClient.lastEndpoint?.queryItems?.contains(where: { $0.value == "eq.\(chapterID.uuidString)" }) == true)
    }

    @Test func fetchExercises_usesChapterIDQuery() async throws {
        let chapterID = UUID()
        mockClient.requestHandler = { _ in try JSONEncoder().encode([Exercise]()) }

        _ = try await sut.fetchExercises(for: chapterID)

        #expect(mockClient.lastEndpoint?.path == "exercises")
    }

    @Test func fetchChapters_whenNetworkFails_throwsError() async {
        mockClient.requestHandler = { _ in throw NetworkError.transportError }

        await #expect(throws: NetworkError.self) {
            try await sut.fetchChapters()
        }
    }
}
