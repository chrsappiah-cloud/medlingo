import Foundation
@testable import medlingo

final class ChapterServiceMock: ChapterServiceProtocol {
    var fetchChaptersResult: Result<[Chapter], Error> = .success([])
    var fetchLessonsResult: Result<[Lesson], Error> = .success([])
    var fetchExercisesResult: Result<[Exercise], Error> = .success([])

    private(set) var fetchChaptersCallCount = 0
    private(set) var fetchLessonsCallCount = 0
    private(set) var lastFetchLessonsChapterID: UUID?
    private(set) var fetchExercisesCallCount = 0
    private(set) var lastFetchExercisesChapterID: UUID?

    func fetchChapters() async throws -> [Chapter] {
        fetchChaptersCallCount += 1
        return try fetchChaptersResult.get()
    }

    func fetchLessons(for chapterID: UUID) async throws -> [Lesson] {
        fetchLessonsCallCount += 1
        lastFetchLessonsChapterID = chapterID
        return try fetchLessonsResult.get()
    }

    func fetchExercises(for chapterID: UUID) async throws -> [Exercise] {
        fetchExercisesCallCount += 1
        lastFetchExercisesChapterID = chapterID
        return try fetchExercisesResult.get()
    }
}
