import Foundation

struct Attempt: Identifiable, Codable, Hashable {
    let id: UUID
    let learnerID: UUID
    let exerciseID: UUID
    let chapterID: UUID
    let score: Double
    let totalQuestions: Int
    let correctAnswers: Int
    let startedAt: Date
    let completedAt: Date?
    let items: [AttemptItem]
}

struct AttemptItem: Identifiable, Codable, Hashable {
    let id: UUID
    let attemptID: UUID
    let questionID: UUID
    let givenAnswer: String
    let isCorrect: Bool
    let timeTakenSeconds: Int?
}
