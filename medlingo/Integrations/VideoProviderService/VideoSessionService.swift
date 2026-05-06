import Foundation

protocol VideoSessionServiceProtocol {
    func createRoom(sessionID: UUID) async throws -> VideoRoomInfo
    func joinRoom(roomURL: URL, token: String) async throws
    func leaveRoom() async throws
}

struct VideoRoomInfo: Codable {
    let roomURL: URL
    let token: String
    let expiresAt: Date
}

@MainActor
final class VideoSessionService: VideoSessionServiceProtocol {
    private let client: NetworkClientProtocol

    init(client: NetworkClientProtocol = SupabaseManager.shared.functionsClient) {
        self.client = client
    }

    func createRoom(sessionID: UUID) async throws -> VideoRoomInfo {
        let body = try JSONEncoder().encode(["session_id": sessionID.uuidString])
        return try await client.request(Endpoint(
            path: "sessions/create-room",
            method: .post,
            body: body
        ))
    }

    func joinRoom(roomURL: URL, token: String) async throws {
        // Integrate with Daily/Agora/Zoom SDK
        // This would launch the video SDK's native view
    }

    func leaveRoom() async throws {
        // Clean up video session resources
    }
}
