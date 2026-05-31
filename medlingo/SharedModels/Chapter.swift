import Foundation

struct Chapter: Identifiable, Codable, Hashable {
    let id: UUID
    let number: Int
    let title: String
    let summary: String
    let estimatedMinutes: Int
    let coverArtURL: URL?
    let accentColorHex: String
    let prerequisiteIDs: [UUID]
    let unlockRule: UnlockRule

    enum UnlockRule: String, Codable, Hashable {
        case free
        case sequential
        case institutional
    }
}
