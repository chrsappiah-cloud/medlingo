import Foundation

protocol AnalyticsServiceProtocol {
    func track(_ event: AnalyticsEvent)
    func setUserProperties(_ properties: [String: String])
    func flush()
}

enum AnalyticsEvent {
    case lessonStarted(chapterID: UUID, lessonID: UUID)
    case lessonCompleted(chapterID: UUID, lessonID: UUID, durationSeconds: Int)
    case exerciseAttempted(type: String, chapterID: UUID, score: Double)
    case exerciseCompleted(type: String, chapterID: UUID, score: Double)
    case chapterUnlocked(chapterID: UUID)
    case chapterCompleted(chapterID: UUID, masteryScore: Double)
    case sessionBooked(sessionID: UUID, tutorID: UUID)
    case sessionAttended(sessionID: UUID, durationMinutes: Int)
    case purchaseInitiated(productID: String)
    case purchaseCompleted(productID: String, revenue: Decimal)
    case purchaseFailed(productID: String, reason: String)
    case streakUpdated(count: Int)
    case appOpened
    case screenViewed(name: String)

    var name: String {
        switch self {
        case .lessonStarted: return "lesson_started"
        case .lessonCompleted: return "lesson_completed"
        case .exerciseAttempted: return "exercise_attempted"
        case .exerciseCompleted: return "exercise_completed"
        case .chapterUnlocked: return "chapter_unlocked"
        case .chapterCompleted: return "chapter_completed"
        case .sessionBooked: return "session_booked"
        case .sessionAttended: return "session_attended"
        case .purchaseInitiated: return "purchase_initiated"
        case .purchaseCompleted: return "purchase_completed"
        case .purchaseFailed: return "purchase_failed"
        case .streakUpdated: return "streak_updated"
        case .appOpened: return "app_opened"
        case .screenViewed: return "screen_viewed"
        }
    }
}

final class AnalyticsService: AnalyticsServiceProtocol {
    static let shared = AnalyticsService()

    private var eventQueue: [AnalyticsEvent] = []

    func track(_ event: AnalyticsEvent) {
        eventQueue.append(event)
        if eventQueue.count >= 10 {
            flush()
        }
    }

    func setUserProperties(_ properties: [String: String]) {
        // TODO: Forward to analytics backend
    }

    func flush() {
        guard !eventQueue.isEmpty else { return }
        let events = eventQueue
        eventQueue.removeAll()
        Task {
            // TODO: Batch send events to Supabase analytics table
            _ = events
        }
    }
}
