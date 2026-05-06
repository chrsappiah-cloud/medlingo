import Foundation

@MainActor
final class SessionService: SessionServiceProtocol {
    private let client: NetworkClientProtocol
    private let functionsClient: NetworkClientProtocol

    init(
        client: NetworkClientProtocol = SupabaseManager.shared.networkClient,
        functionsClient: NetworkClientProtocol = SupabaseManager.shared.functionsClient
    ) {
        self.client = client
        self.functionsClient = functionsClient
    }

    func fetchAvailableSessions() async throws -> [TutorSession] {
        let now = ISO8601DateFormatter().string(from: Date())
        return try await client.request(Endpoint(path: "sessions", queryItems: [
            URLQueryItem(name: "status", value: "eq.scheduled"),
            URLQueryItem(name: "starts_at", value: "gt.\(now)"),
            URLQueryItem(name: "order", value: "starts_at.asc")
        ]))
    }

    func bookSession(sessionID: UUID, learnerID: UUID) async throws -> Booking {
        let payload: [String: String] = [
            "session_id": sessionID.uuidString,
            "learner_id": learnerID.uuidString,
            "status": "confirmed"
        ]
        let body = try JSONEncoder().encode(payload)
        return try await client.request(Endpoint(path: "bookings", method: .post, body: body))
    }

    func cancelBooking(bookingID: UUID) async throws {
        let payload = try JSONEncoder().encode(["status": "cancelled"])
        try await client.request(Endpoint(
            path: "bookings",
            method: .patch,
            body: payload,
            queryItems: [URLQueryItem(name: "id", value: "eq.\(bookingID.uuidString)")]
        ))
    }

    func createRoomToken(sessionID: UUID) async throws -> (url: URL, token: String) {
        let body = try JSONEncoder().encode(["session_id": sessionID.uuidString])
        let response: [String: String] = try await functionsClient.request(
            Endpoint(path: "sessions-create-room", method: .post, body: body)
        )
        guard let token = response["token"],
              let urlString = response["room_url"],
              let url = URL(string: urlString) else {
            throw NetworkError.invalidResponse
        }
        return (url, token)
    }
}
