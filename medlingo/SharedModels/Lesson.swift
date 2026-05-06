import Foundation

struct Lesson: Identifiable, Codable, Hashable {
    let id: UUID
    let chapterID: UUID
    let orderIndex: Int
    let title: String
    let content: String
    let type: LessonType
    let estimatedMinutes: Int
    let mediaAssets: [MediaAsset]

    enum LessonType: String, Codable, Hashable {
        case explanation
        case anatomy
        case disorders
        case procedures
        case abbreviations
        case practicalTask
    }
}

struct MediaAsset: Identifiable, Codable, Hashable {
    let id: UUID
    let url: URL
    let type: MediaType
    let caption: String?

    enum MediaType: String, Codable, Hashable {
        case image
        case diagram
        case video
        case pdf
        case audio
    }
}
