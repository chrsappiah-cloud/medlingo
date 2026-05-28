import Foundation
import Observation

/// Unified AI generation service that routes to open-source models
/// via Replicate (Stable Diffusion XL for images, Stable Video Diffusion for video)
/// and Apple-native on-device generation when available.
///
/// Falls back to demo content when API keys are not configured.
@MainActor
@Observable
final class InVideoAIService {
    static let shared = InVideoAIService()

    private let functionsClient: NetworkClientProtocol
    var launchConfiguration: AppLaunchConfiguration = .shared

    private var isDemo: Bool {
        if launchConfiguration.forcesDemoAIGeneration {
            return true
        }
        return !SupabaseManager.shared.isConfigured || Config.replicateAPIToken.isEmpty
    }

    struct AIModel: Identifiable, Hashable {
        let id: String
        let name: String
        let provider: String
        let mediaType: ArtworkMediaType
        let description: String
        let maxWidth: Int
        let maxHeight: Int
    }

    static let availableModels: [AIModel] = [
        AIModel(
            id: "stability-ai/sdxl",
            name: "Stable Diffusion XL",
            provider: "Replicate",
            mediaType: .image,
            description: "High-quality photorealistic and artistic image generation",
            maxWidth: 1536, maxHeight: 1536
        ),
        AIModel(
            id: "stability-ai/stable-video-diffusion",
            name: "Stable Video Diffusion",
            provider: "Replicate",
            mediaType: .video,
            description: "Generate short video clips from text or image prompts",
            maxWidth: 1024, maxHeight: 576
        ),
        AIModel(
            id: "black-forest-labs/flux-1.1-pro",
            name: "FLUX 1.1 Pro",
            provider: "Replicate",
            mediaType: .image,
            description: "State-of-the-art text-to-image with exceptional prompt adherence",
            maxWidth: 1440, maxHeight: 1440
        ),
        AIModel(
            id: "tencent/hunyuan-video",
            name: "HunyuanVideo",
            provider: "Replicate",
            mediaType: .video,
            description: "Open-source text-to-video with cinematic quality",
            maxWidth: 1280, maxHeight: 720
        ),
        AIModel(
            id: "apple/ml-stable-diffusion",
            name: "Apple Core ML",
            provider: "On-Device",
            mediaType: .image,
            description: "Fast on-device generation using Apple Neural Engine",
            maxWidth: 1024, maxHeight: 1024
        ),
    ]

    struct StylePreset: Identifiable, Hashable {
        let id: String
        let name: String
        let icon: String
        let promptSuffix: String
    }

    static let stylePresets: [StylePreset] = [
        StylePreset(id: "medical-illustration", name: "Medical Illustration", icon: "cross.case.fill", promptSuffix: ", detailed medical illustration, anatomical accuracy, scientific diagram style, clean white background"),
        StylePreset(id: "photorealistic", name: "Photorealistic", icon: "camera.fill", promptSuffix: ", photorealistic, 8k uhd, highly detailed, sharp focus, professional photography"),
        StylePreset(id: "digital-art", name: "Digital Art", icon: "paintbrush.fill", promptSuffix: ", digital art, vibrant colors, detailed, artstation trending"),
        StylePreset(id: "watercolor", name: "Watercolor", icon: "drop.fill", promptSuffix: ", watercolor painting, soft edges, artistic, beautiful brush strokes"),
        StylePreset(id: "3d-render", name: "3D Render", icon: "cube.fill", promptSuffix: ", 3D render, octane render, volumetric lighting, highly detailed"),
        StylePreset(id: "cinematic", name: "Cinematic", icon: "film", promptSuffix: ", cinematic shot, dramatic lighting, movie still, anamorphic lens"),
        StylePreset(id: "anime", name: "Anime Style", icon: "sparkles", promptSuffix: ", anime style, studio ghibli inspired, cel shaded, vibrant"),
        StylePreset(id: "none", name: "No Style", icon: "minus.circle", promptSuffix: ""),
    ]

    init(
        client: NetworkClientProtocol? = nil,
        launchConfiguration: AppLaunchConfiguration = .shared
    ) {
        self.functionsClient = client ?? SupabaseManager.shared.functionsClient
        self.launchConfiguration = launchConfiguration
    }

    // MARK: - Generation

    func generateArtwork(request: ArtworkGenerationRequest) async throws -> GeneratedArtwork {
        if isDemo {
            return try await demoGenerate(request: request)
        }

        let body = try JSONEncoder().encode(request)
        let endpoint = Endpoint(
            path: "ai-art/generate",
            method: .post,
            body: body
        )

        struct GenerationResponse: Decodable {
            let id: String
            let status: String
            let mediaUrl: String?
            let thumbnailUrl: String?
            let seed: Int?
        }

        let response: GenerationResponse = try await functionsClient.request(endpoint)

        return GeneratedArtwork(
            id: UUID(),
            ownerID: AppState.shared.currentUserID ?? UUID(),
            prompt: request.prompt,
            negativePrompt: request.negativePrompt,
            mediaType: request.mediaType,
            status: .generating,
            mediaURL: response.mediaUrl.flatMap(URL.init(string:)),
            thumbnailURL: response.thumbnailUrl.flatMap(URL.init(string:)),
            provider: request.model.components(separatedBy: "/").first ?? "replicate",
            modelName: request.model,
            width: request.width,
            height: request.height,
            durationSeconds: request.durationSeconds,
            seed: response.seed,
            createdAt: Date(),
            completedAt: nil,
            isFavorite: false,
            tags: extractTags(from: request.prompt)
        )
    }

    func pollStatus(artworkID: UUID) async throws -> GeneratedArtwork? {
        if isDemo { return nil }

        let endpoint = Endpoint(
            path: "ai-art/status",
            queryItems: [URLQueryItem(name: "id", value: artworkID.uuidString)]
        )

        return try await functionsClient.request(endpoint)
    }

    /// Generates and polls until completion, calling the progress handler as status changes.
    func generateAndAwait(
        request: ArtworkGenerationRequest,
        onProgress: @escaping (Double, String) -> Void
    ) async throws -> GeneratedArtwork {
        onProgress(0.1, "Submitting to AI model...")

        var artwork = try await generateArtwork(request: request)
        onProgress(0.3, "Generating \(request.mediaType.displayName.lowercased())...")

        if isDemo {
            onProgress(1.0, "Complete")
            return artwork
        }

        let timeout: TimeInterval = request.mediaType == .video ? 600 : 180
        let deadline = Date().addingTimeInterval(timeout)
        var progressValue = 0.3

        while Date() < deadline {
            try await Task.sleep(nanoseconds: 3_000_000_000)
            progressValue = min(progressValue + 0.05, 0.95)

            if let updated = try await pollStatus(artworkID: artwork.id) {
                artwork = updated
                switch updated.status {
                case .completed:
                    onProgress(1.0, "Complete")
                    return updated
                case .failed:
                    throw InVideoAIError.generationFailed
                case .generating:
                    onProgress(progressValue, "Still generating...")
                case .queued:
                    onProgress(progressValue, "Queued, waiting for capacity...")
                }
            }
        }

        throw InVideoAIError.timeout
    }

    func enhancePrompt(_ rawPrompt: String, style: StylePreset?) -> String {
        var enhanced = rawPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
        if let style, style.id != "none" {
            enhanced += style.promptSuffix
        }
        return enhanced
    }

    func models(for mediaType: ArtworkMediaType) -> [AIModel] {
        Self.availableModels.filter { $0.mediaType == mediaType }
    }

    // MARK: - Demo Mode

    private func demoGenerate(request: ArtworkGenerationRequest) async throws -> GeneratedArtwork {
        try await Task.sleep(nanoseconds: 2_500_000_000)

        let demoURL: URL
        if request.mediaType == .video {
            demoURL = URL(string: "https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/720/Big_Buck_Bunny_720_10s_1MB.mp4")!
        } else {
            demoURL = URL(string: "https://picsum.photos/\(request.width)/\(request.height)")!
        }

        return GeneratedArtwork(
            id: UUID(),
            ownerID: AppState.shared.currentUserID ?? UUID(),
            prompt: request.prompt,
            negativePrompt: request.negativePrompt,
            mediaType: request.mediaType,
            status: .completed,
            mediaURL: demoURL,
            thumbnailURL: demoURL,
            provider: "demo",
            modelName: request.model,
            width: request.width,
            height: request.height,
            durationSeconds: request.mediaType == .video ? 10 : nil,
            seed: Int.random(in: 1...999999),
            createdAt: Date(),
            completedAt: Date(),
            isFavorite: false,
            tags: extractTags(from: request.prompt)
        )
    }

    private func extractTags(from prompt: String) -> [String] {
        let stopWords: Set<String> = ["a", "an", "the", "of", "in", "on", "at", "to", "for", "with", "and", "or", "is", "are", "was", "were"]
        return prompt
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.count > 2 && !stopWords.contains($0) }
            .prefix(8)
            .map { String($0) }
    }
}

enum InVideoAIError: Error, LocalizedError {
    case generationFailed
    case timeout
    case invalidPrompt
    case modelUnavailable
    case quotaExceeded

    var errorDescription: String? {
        switch self {
        case .generationFailed: return "AI generation failed. Please try again."
        case .timeout: return "Generation timed out. Try a simpler prompt or image mode."
        case .invalidPrompt: return "Please provide a valid prompt."
        case .modelUnavailable: return "Selected model is currently unavailable."
        case .quotaExceeded: return "Generation quota exceeded. Upgrade to continue."
        }
    }
}
