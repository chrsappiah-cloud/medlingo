import Foundation

struct ChatMessage: Identifiable, Codable, Hashable {
    let id: UUID
    let senderID: UUID
    let recipientID: UUID
    let content: String
    let sentAt: Date
    let readAt: Date?
    let attachmentURL: URL?

    var isRead: Bool {
        readAt != nil
    }
}
