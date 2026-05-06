import Foundation

@MainActor
final class MessagingService: MessagingServiceProtocol {
    private let client: NetworkClientProtocol
    private var realtimeTask: Task<Void, Never>?
    private var lastSeenTimestamp: Date?

    init(client: NetworkClientProtocol? = nil) {
        self.client = client ?? SupabaseManager.shared.networkClient
    }

    func fetchMessages(for userID: UUID) async throws -> [ChatMessage] {
        let messages: [ChatMessage] = try await client.request(Endpoint(path: "messages", queryItems: [
            URLQueryItem(name: "or", value: "(sender_id.eq.\(userID.uuidString),recipient_id.eq.\(userID.uuidString))"),
            URLQueryItem(name: "order", value: "sent_at.asc")
        ]))
        lastSeenTimestamp = messages.last?.sentAt ?? Date()
        return messages
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

    /// Subscribes to new messages using Supabase Realtime-style polling.
    /// Polls for messages newer than the last seen timestamp every 3 seconds.
    /// When Supabase Swift SDK adds native Realtime, swap to WebSocket channel.
    func subscribeToMessages(userID: UUID, callback: @escaping ([ChatMessage]) -> Void) {
        realtimeTask?.cancel()
        realtimeTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                guard !Task.isCancelled, let self else { return }

                let since = self.lastSeenTimestamp ?? Date.distantPast
                let isoTimestamp = ISO8601DateFormatter().string(from: since)

                do {
                    let newMessages: [ChatMessage] = try await self.client.request(Endpoint(
                        path: "messages",
                        queryItems: [
                            URLQueryItem(name: "recipient_id", value: "eq.\(userID.uuidString)"),
                            URLQueryItem(name: "sent_at", value: "gt.\(isoTimestamp)"),
                            URLQueryItem(name: "order", value: "sent_at.asc")
                        ]
                    ))
                    if !newMessages.isEmpty {
                        self.lastSeenTimestamp = newMessages.last?.sentAt
                        callback(newMessages)
                    }
                } catch {
                    // Network blip — retry on next cycle
                }
            }
        }
    }

    func unsubscribe() {
        realtimeTask?.cancel()
        realtimeTask = nil
    }
}
