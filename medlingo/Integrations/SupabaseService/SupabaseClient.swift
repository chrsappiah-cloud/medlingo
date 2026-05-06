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
    func createRoomToken(sessionID: UUID) async throws -> String
}

protocol EntitlementServiceProtocol {
    func fetchEntitlements(for userID: UUID) async throws -> [Entitlement]
    func verifyPurchase(transactionData: Data) async throws -> Entitlement
    func overrideEntitlement(userID: UUID, productID: String, status: Entitlement.EntitlementStatus) async throws
}

final class SupabaseManager {
    static let shared = SupabaseManager()

    let projectURL: URL
    let anonKey: String

    private init() {
        // These should come from a config/plist in production
        self.projectURL = URL(string: "https://your-project.supabase.co")!
        self.anonKey = "your-anon-key"
    }

    lazy var networkClient: NetworkClient = {
        NetworkClient(
            baseURL: projectURL.appendingPathComponent("rest/v1"),
            tokenProvider: { [weak self] in
                // Return current auth token
                return nil
            }
        )
    }()

    lazy var functionsClient: NetworkClient = {
        NetworkClient(
            baseURL: projectURL.appendingPathComponent("functions/v1"),
            tokenProvider: {
                return nil
            }
        )
    }()
}

final class ChapterService: ChapterServiceProtocol {
    private let client: NetworkClientProtocol

    init(client: NetworkClientProtocol = SupabaseManager.shared.networkClient) {
        self.client = client
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

final class PurchaseVerificationService {
    private let client: NetworkClientProtocol

    init(client: NetworkClientProtocol = SupabaseManager.shared.functionsClient) {
        self.client = client
    }

    func verifyTransaction(payload: Data) async throws -> Entitlement {
        try await client.request(Endpoint(
            path: "purchase/verify",
            method: .post,
            body: payload
        ))
    }
}
