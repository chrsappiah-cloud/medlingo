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

    var properties: [String: String] {
        switch self {
        case .lessonStarted(let chapterID, let lessonID):
            return ["chapter_id": chapterID.uuidString, "lesson_id": lessonID.uuidString]
        case .lessonCompleted(let chapterID, let lessonID, let duration):
            return ["chapter_id": chapterID.uuidString, "lesson_id": lessonID.uuidString, "duration_seconds": "\(duration)"]
        case .exerciseAttempted(let type, let chapterID, let score):
            return ["type": type, "chapter_id": chapterID.uuidString, "score": "\(score)"]
        case .exerciseCompleted(let type, let chapterID, let score):
            return ["type": type, "chapter_id": chapterID.uuidString, "score": "\(score)"]
        case .chapterUnlocked(let chapterID):
            return ["chapter_id": chapterID.uuidString]
        case .chapterCompleted(let chapterID, let mastery):
            return ["chapter_id": chapterID.uuidString, "mastery_score": "\(mastery)"]
        case .sessionBooked(let sessionID, let tutorID):
            return ["session_id": sessionID.uuidString, "tutor_id": tutorID.uuidString]
        case .sessionAttended(let sessionID, let duration):
            return ["session_id": sessionID.uuidString, "duration_minutes": "\(duration)"]
        case .purchaseInitiated(let productID):
            return ["product_id": productID]
        case .purchaseCompleted(let productID, let revenue):
            return ["product_id": productID, "revenue": "\(revenue)"]
        case .purchaseFailed(let productID, let reason):
            return ["product_id": productID, "reason": reason]
        case .streakUpdated(let count):
            return ["count": "\(count)"]
        case .appOpened:
            return [:]
        case .screenViewed(let name):
            return ["screen_name": name]
        }
    }
}

final class AnalyticsService: AnalyticsServiceProtocol {
    static let shared = AnalyticsService()

    private var eventQueue: [AnalyticsEvent] = []
    private var userProperties: [String: String] = [:]
    private let batchThreshold = 10
    private var flushTask: Task<Void, Never>?

    func track(_ event: AnalyticsEvent) {
        eventQueue.append(event)
        if eventQueue.count >= batchThreshold {
            flush()
        }
    }

    func setUserProperties(_ properties: [String: String]) {
        userProperties.merge(properties) { _, new in new }

        Task {
            let payload = try? JSONEncoder().encode(properties)
            try? await SupabaseManager.shared.functionsClient.request(Endpoint(
                path: "analytics/user-properties",
                method: .post,
                body: payload
            ))
        }
    }

    func flush() {
        guard !eventQueue.isEmpty else { return }
        let events = eventQueue
        eventQueue.removeAll()

        flushTask?.cancel()
        flushTask = Task {
            let rows = events.map { event in
                AnalyticsRow(
                    eventName: event.name,
                    properties: event.properties,
                    timestamp: ISO8601DateFormatter().string(from: Date())
                )
            }

            guard let body = try? JSONEncoder().encode(rows) else { return }

            do {
                try await SupabaseManager.shared.networkClient.request(Endpoint(
                    path: "analytics_events",
                    method: .post,
                    body: body
                ))
            } catch {
                // Re-enqueue on failure for next flush cycle
                await MainActor.run { eventQueue.insert(contentsOf: events, at: 0) }
            }
        }
    }
}

private struct AnalyticsRow: Encodable {
    let eventName: String
    let properties: [String: String]
    let timestamp: String
}
