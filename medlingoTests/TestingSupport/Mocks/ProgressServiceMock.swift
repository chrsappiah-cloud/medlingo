import Foundation
@testable import medlingo

final class ProgressServiceMock: ProgressServiceProtocol {
    var submitAttemptResult: Result<Void, Error> = .success(())
    var fetchProgressResult: Result<[CachedProgress], Error> = .success([])

    private(set) var submitAttemptCallCount = 0
    private(set) var lastSubmittedAttempt: Attempt?
    private(set) var fetchProgressCallCount = 0

    func submitAttempt(_ attempt: Attempt) async throws {
        submitAttemptCallCount += 1
        lastSubmittedAttempt = attempt
        try submitAttemptResult.get()
    }

    func fetchProgress(for userID: UUID) async throws -> [CachedProgress] {
        fetchProgressCallCount += 1
        return try fetchProgressResult.get()
    }

    func recomputeProgress(for userID: UUID) async throws {}
}
