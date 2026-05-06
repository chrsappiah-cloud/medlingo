import Foundation

@MainActor
final class MessagingService: MessagingServiceProtocol {
    private let client: NetworkClientProtocol

    init(client: NetworkClientProtocol? = nil) {
        self.client = client ?? SupabaseManager.shared.networkClient
    }

    func fetchMessages(for userID: UUID) async throws -> [ChatMessage] {
        try await client.request(Endpoint(path: "messages", queryItems: [
            URLQueryItem(name: "or", value: "(sender_id.eq.\(userID.uuidString),recipient_id.eq.\(userID.uuidString))"),
            URLQueryItem(name: "order", value: "sent_at.asc")
        ]))
    }

    func sendMessage(from senderID: UUID, to recipientID: UUID, content: String) async throws -> ChatMessage {
        let payload: [String: String] = [
            "sender_id": senderID.uuidString,
            "recipient_id": recipientID.uuidString,
            "content": content
        ]
        let body = try JSONEncoder().encode(payload)
        return try await client.request(Endpoint(path: "messages", method: .post, body: body))
    }

    func markAsRead(messageID: UUID) async throws {
        let payload = try JSONEncoder().encode(["read_at": ISO8601DateFormatter().string(from: Date())])
        try await client.request(Endpoint(
            path: "messages",
            method: .patch,
            body: payload,
            queryItems: [URLQueryItem(name: "id", value: "eq.\(messageID.uuidString)")]
        ))
    }

    /// Realtime subscription for incoming messages.
    /// In production, this would use Supabase Realtime WebSocket channels
    /// to listen for INSERT events on the messages table filtered by recipient_id.
    /// Placeholder: polling or WebSocket integration to be added.
    func subscribeToMessages(userID: UUID, callback: @escaping ([ChatMessage]) -> Void) {
        // TODO: Integrate Supabase Realtime channel subscription
        // channel = supabase.realtime.channel("messages:\(userID)")
        // channel.on(.insert) { message in callback([message]) }
        // channel.subscribe()
    }
}
