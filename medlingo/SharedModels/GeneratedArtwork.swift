import Foundation

enum ArtworkMediaType: String, Codable, CaseIterable, Identifiable {
    case image
    case video

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .image: return "Image"
        case .video: return "Video"
        }
    }

    var icon: String {
        switch self {
        case .image: return "photo.artframe"
        case .video: return "film"
        }
    }
}

enum ArtworkGenerationStatus: String, Codable {
    case queued
    case generating
    case completed
    case failed
}

struct GeneratedArtwork: Identifiable, Codable, Hashable {
    let id: UUID
    let ownerID: UUID
    let prompt: String
    let negativePrompt: String?
    let mediaType: ArtworkMediaType
    let status: ArtworkGenerationStatus
    let mediaURL: URL?
    let thumbnailURL: URL?
    let provider: String
    let modelName: String
    let width: Int
    let height: Int
    let durationSeconds: Int?
    let seed: Int?
    let createdAt: Date
    let completedAt: Date?
    let isFavorite: Bool
    let tags: [String]

    var isVideo: Bool { mediaType == .video }
    var aspectRatioLabel: String { "\(width)x\(height)" }
    var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
}

struct ArtworkGenerationRequest: Encodable {
    let prompt: String
    let negativePrompt: String?
    let mediaType: ArtworkMediaType
    let width: Int
    let height: Int
    let durationSeconds: Int?
    let model: String
    let seed: Int?
    let stylePreset: String?
}
