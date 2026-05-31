import Foundation
import SwiftData

@Model
final class CachedChapter {
    @Attribute(.unique) var chapterID: UUID
    var number: Int
    var title: String
    var summary: String
    var estimatedMinutes: Int
    var coverArtURL: String?
    var accentColorHex: String
    var lastSyncedAt: Date

    init(from chapter: Chapter) {
        self.chapterID = chapter.id
        self.number = chapter.number
        self.title = chapter.title
        self.summary = chapter.summary
        self.estimatedMinutes = chapter.estimatedMinutes
        self.coverArtURL = chapter.coverArtURL?.absoluteString
        self.accentColorHex = chapter.accentColorHex
        self.lastSyncedAt = Date()
    }
}

@Model
final class CachedProgress {
    @Attribute(.unique) var chapterID: UUID
    var userID: UUID
    var lessonsCompleted: Int
    var totalLessons: Int
    var exercisesCompleted: Int
    var totalExercises: Int
    var masteryScore: Double
    var lastStudiedAt: Date

    init(chapterID: UUID, userID: UUID) {
        self.chapterID = chapterID
        self.userID = userID
        self.lessonsCompleted = 0
        self.totalLessons = 0
        self.exercisesCompleted = 0
        self.totalExercises = 0
        self.masteryScore = 0
        self.lastStudiedAt = Date()
    }

    var completionPercentage: Double {
        guard totalLessons > 0 else { return 0 }
        return Double(lessonsCompleted) / Double(totalLessons)
    }
}

@Model
final class PendingSyncAction {
    var actionType: String
    var payload: Data
    var createdAt: Date
    var retryCount: Int

    init(actionType: String, payload: Data) {
        self.actionType = actionType
        self.payload = payload
        self.createdAt = Date()
        self.retryCount = 0
    }
}
