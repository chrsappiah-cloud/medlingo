import Foundation

protocol ChapterServiceProtocol {
    func fetchChapters() async throws -> [Chapter]
    func fetchLessons(for chapterID: UUID) async throws -> [Lesson]
    func fetchExercises(for chapterID: UUID) async throws -> [Exercise]
}

protocol ProgressServiceProtocol {
    func fetchProgress(for userID: UUID) async throws -> [CachedProgress]
    func submitAttempt(_ attempt: Attempt) async throws
    func recomputeProgress(for userID: UUID) async throws
}

protocol SessionServiceProtocol {
    func fetchAvailableSessions() async throws -> [TutorSession]
    func bookSession(sessionID: UUID, learnerID: UUID) async throws -> Booking
    func cancelBooking(bookingID: UUID) async throws
    func createRoomToken(sessionID: UUID) async throws -> (url: URL, token: String)
}

protocol EntitlementServiceProtocol {
    func fetchEntitlements(for userID: UUID) async throws -> [Entitlement]
    func verifyPurchase(transactionID: String, productID: String, userID: UUID, signedPayload: String) async throws -> Entitlement
    func overrideEntitlement(userID: UUID, productID: String, status: Entitlement.EntitlementStatus) async throws
}

protocol MessagingServiceProtocol {
    func fetchMessages(for userID: UUID) async throws -> [ChatMessage]
    func sendMessage(from senderID: UUID, to recipientID: UUID, content: String) async throws -> ChatMessage
    func markAsRead(messageID: UUID) async throws
}

@MainActor
final class ChapterService: ChapterServiceProtocol {
    private let client: NetworkClientProtocol

    init(client: NetworkClientProtocol? = nil) {
        self.client = client ?? SupabaseManager.shared.networkClient
    }

    func fetchChapters() async throws -> [Chapter] {
        try await client.request(Endpoint(path: "chapters", queryItems: [
            URLQueryItem(name: "order", value: "number.asc")
        ]))
    }

    func fetchLessons(for chapterID: UUID) async throws -> [Lesson] {
        try await client.request(Endpoint(path: "lessons", queryItems: [
            URLQueryItem(name: "chapter_id", value: "eq.\(chapterID.uuidString)"),
            URLQueryItem(name: "order", value: "order_index.asc")
        ]))
    }

    func fetchExercises(for chapterID: UUID) async throws -> [Exercise] {
        try await client.request(Endpoint(path: "exercises", queryItems: [
            URLQueryItem(name: "chapter_id", value: "eq.\(chapterID.uuidString)")
        ]))
    }
}
