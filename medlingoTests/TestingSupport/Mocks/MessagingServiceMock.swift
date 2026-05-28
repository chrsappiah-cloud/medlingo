import Foundation
@testable import medlingo

final class MessagingServiceMock: MessagingServiceProtocol {
    var fetchMessagesResult: Result<[ChatMessage], Error> = .success([])
    var sendMessageResult: Result<ChatMessage, Error> = .success(ChatMessage(id: UUID(), senderID: UUID(), recipientID: UUID(), content: "test", sentAt: Date(), readAt: nil, attachmentURL: nil))

    private(set) var fetchMessagesCallCount = 0
    private(set) var lastFetchUserID: UUID?
    private(set) var sendMessageCallCount = 0
    private(set) var lastSentRecipientID: UUID?
    private(set) var lastSentContent: String?
    private(set) var markAsReadCallCount = 0
    private(set) var lastMarkedMessageID: UUID?

    func fetchMessages(for userID: UUID) async throws -> [ChatMessage] {
        fetchMessagesCallCount += 1
        lastFetchUserID = userID
        return try fetchMessagesResult.get()
    }

    func sendMessage(from senderID: UUID, to recipientID: UUID, content: String) async throws -> ChatMessage {
        sendMessageCallCount += 1
        lastSentRecipientID = recipientID
        lastSentContent = content
        return try sendMessageResult.get()
    }

    func markAsRead(messageID: UUID) async throws {
        markAsReadCallCount += 1
        lastMarkedMessageID = messageID
    }
}
