import Foundation

enum AIVideoProvider: String, Codable {
    case heygen
    case synthesia
}

enum AIVideoStatus: String, Codable {
    case pending
    case processing
    case completed
    case failed
}

struct AIVideoRequest: Encodable {
    let topic: String
    let script: String
    let avatarId: String
    let voiceId: String
    let language: String
    let durationHint: Int
    let chapterIds: [String]
}

struct AIVideoResponse: Decodable {
    let videoId: String
    let status: AIVideoStatus
    let videoURL: URL?
    let thumbnailURL: URL?
    let estimatedDurationSeconds: Int?
}

struct AITutorVideo: Identifiable, Codable, Hashable {
    let id: UUID
    let videoId: String
    let topic: String
    let script: String
    let avatarName: String
    let videoURL: URL?
    let thumbnailURL: URL?
    let status: AIVideoStatus
    let durationSeconds: Int
    let createdAt: Date
}

struct AIAvatar: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let specialty: String
    let thumbnailURL: URL?
    let voiceId: String
}

protocol AIVideoGenerationServiceProtocol {
    func generateVideo(topic: String, script: String, avatar: AIAvatar) async throws -> AIVideoResponse
    func checkStatus(videoId: String) async throws -> AIVideoResponse
    func fetchAvailableAvatars() async throws -> [AIAvatar]
    func generateScript(for topic: String, chapterContext: String) async throws -> String
    func fetchCachedVideos(for chapterIDs: [UUID]) async throws -> [AITutorVideo]
}

@MainActor
final class AIVideoGenerationService: AIVideoGenerationServiceProtocol {
    static let shared = AIVideoGenerationService()

    private let functionsClient: NetworkClientProtocol

    private var isDemo: Bool { !SupabaseManager.shared.isConfigured }

    init(client: NetworkClientProtocol? = nil) {
        self.functionsClient = client ?? SupabaseManager.shared.functionsClient
    }

    /// Requests AI avatar video generation via Supabase Edge Function.
    /// Falls back to demo mode with sample content when backend is not configured.
    func generateVideo(topic: String, script: String, avatar: AIAvatar) async throws -> AIVideoResponse {
        if isDemo {
            try await Task.sleep(nanoseconds: 2_000_000_000)
            return AIVideoResponse(
                videoId: "demo-\(UUID().uuidString.prefix(8))",
                status: .completed,
                videoURL: DemoContent.videoURL(for: topic),
                thumbnailURL: nil,
                estimatedDurationSeconds: 90
            )
        }

        let request = AIVideoRequest(
            topic: topic,
            script: script,
            avatarId: avatar.id,
            voiceId: avatar.voiceId,
            language: "en",
            durationHint: estimateDuration(script: script),
            chapterIds: []
        )

        let body = try JSONEncoder().encode(request)
        return try await functionsClient.request(Endpoint(
            path: "ai-video/generate",
            method: .post,
            body: body
        ))
    }

    func checkStatus(videoId: String) async throws -> AIVideoResponse {
        if isDemo {
            return AIVideoResponse(
                videoId: videoId,
                status: .completed,
                videoURL: DemoContent.videoURL(for: "demo"),
                thumbnailURL: nil,
                estimatedDurationSeconds: 90
            )
        }
        return try await functionsClient.request(Endpoint(
            path: "ai-video/status",
            queryItems: [URLQueryItem(name: "video_id", value: videoId)]
        ))
    }

    func fetchAvailableAvatars() async throws -> [AIAvatar] {
        if isDemo {
            return DemoContent.avatars
        }
        return try await functionsClient.request(Endpoint(path: "ai-video/avatars"))
    }

    /// Uses server-side LLM to generate an engaging teaching script for the avatar.
    /// In demo mode, returns a pre-written medical terminology script.
    func generateScript(for topic: String, chapterContext: String) async throws -> String {
        if isDemo {
            try await Task.sleep(nanoseconds: 1_500_000_000)
            return DemoContent.script(for: topic)
        }

        struct ScriptRequest: Encodable {
            let topic: String
            let context: String
            let style: String
            let maxWords: Int
        }

        struct ScriptResponse: Decodable {
            let script: String
        }

        let request = ScriptRequest(
            topic: topic,
            context: chapterContext,
            style: "conversational_medical_tutor",
            maxWords: 300
        )

        let body = try JSONEncoder().encode(request)
        let response: ScriptResponse = try await functionsClient.request(Endpoint(
            path: "ai-video/generate-script",
            method: .post,
            body: body
        ))
        return response.script
    }

    /// Fetches previously generated videos from Supabase cache.
    func fetchCachedVideos(for chapterIDs: [UUID]) async throws -> [AITutorVideo] {
        if isDemo { return [] }
        let ids = chapterIDs.map(\.uuidString).joined(separator: ",")
        let client = SupabaseManager.shared.networkClient
        return try await client.request(Endpoint(
            path: "ai_tutor_videos",
            queryItems: [
                URLQueryItem(name: "chapter_ids", value: "ov.{\(ids)}"),
                URLQueryItem(name: "status", value: "eq.completed"),
                URLQueryItem(name: "order", value: "created_at.desc")
            ]
        ))
    }

    /// Polls until video generation completes or times out.
    func awaitCompletion(videoId: String, timeout: TimeInterval = 300) async throws -> AIVideoResponse {
        if isDemo {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            return AIVideoResponse(
                videoId: videoId,
                status: .completed,
                videoURL: DemoContent.videoURL(for: "demo"),
                thumbnailURL: nil,
                estimatedDurationSeconds: 90
            )
        }

        let deadline = Date().addingTimeInterval(timeout)

        while Date() < deadline {
            let response = try await checkStatus(videoId: videoId)
            switch response.status {
            case .completed:
                return response
            case .failed:
                throw AIVideoError.generationFailed
            case .pending, .processing:
                try await Task.sleep(nanoseconds: 5_000_000_000)
            }
        }

        throw AIVideoError.timeout
    }

    private func estimateDuration(script: String) -> Int {
        let wordCount = script.split(separator: " ").count
        return max(30, (wordCount / 150) * 60)
    }
}

// MARK: - Demo Content (used when Supabase is not configured)

private enum DemoContent {
    static let avatars: [AIAvatar] = [
        AIAvatar(id: "demo-dr-chen", name: "Dr. Elena Chen", specialty: "Medical Terminology", thumbnailURL: nil, voiceId: "demo-voice-1"),
        AIAvatar(id: "demo-prof-adams", name: "Prof. James Adams", specialty: "Anatomy & Physiology", thumbnailURL: nil, voiceId: "demo-voice-2")
    ]

    static func videoURL(for topic: String) -> URL {
        URL(string: "https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/720/Big_Buck_Bunny_720_10s_1MB.mp4")!
    }

    static func script(for topic: String) -> String {
        let scripts: [String: String] = [
            "Cardiovascular Terms": """
                Welcome to your AI tutor session on Cardiovascular Terminology. \
                Today we'll break down the key prefixes and suffixes you need to master. \
                Let's start with 'cardi/o' — meaning heart. When you see this root, \
                you know we're discussing the heart. 'Angi/o' refers to blood vessels. \
                Combined with suffixes like '-itis' for inflammation, we get 'carditis' — \
                inflammation of the heart, or 'angiitis' — inflammation of blood vessels. \
                The suffix '-emia' means blood condition. 'Ischemia' means restricted blood flow. \
                'Bradycardia' uses 'brady-' meaning slow, plus 'cardia' — so it's a slow heart rate. \
                'Tachycardia' is the opposite: 'tachy-' means fast. \
                Practice these roots and you'll decode hundreds of cardiovascular terms with confidence.
                """,
            "Nervous System": """
                Let's explore the Nervous System terminology together. \
                The root 'neur/o' means nerve — you'll see it everywhere in neurology. \
                'Encephal/o' refers to the brain, and 'myel/o' can mean spinal cord or bone marrow. \
                'Cephal/o' means head — so 'cephalgia' is simply a headache. \
                The suffix '-algia' means pain. 'Neuralgia' is nerve pain. \
                '-plegia' means paralysis: 'hemiplegia' is paralysis of one side of the body. \
                'Cerebr/o' refers to the cerebrum, the largest part of the brain. \
                A 'cerebrovascular accident' — or CVA — is what we commonly call a stroke. \
                Remember: prefixes tell you where or how much, roots tell you what, \
                and suffixes tell you the condition or procedure.
                """,
            "Musculoskeletal": """
                Welcome! Today we're covering Musculoskeletal terminology. \
                'Oste/o' means bone — 'osteoporosis' is porous bones, a loss of bone density. \
                'Arthr/o' means joint — 'arthritis' is inflammation of a joint. \
                'My/o' refers to muscle, and 'myalgia' means muscle pain. \
                The suffix '-ectomy' means surgical removal. An 'appendectomy' removes the appendix. \
                '-plasty' means surgical repair: 'arthroplasty' is joint replacement surgery. \
                'Chondr/o' means cartilage. 'Chondritis' is cartilage inflammation. \
                The prefix 'inter-' means between: 'intervertebral' means between vertebrae. \
                'Sub-' means below: 'subcutaneous' means beneath the skin. \
                Master these building blocks and complex terms become simple puzzles to solve.
                """
        ]

        return scripts[topic] ?? """
            Welcome to your personalized AI tutor session on \(topic). \
            Medical terminology follows a logical pattern of prefixes, roots, and suffixes. \
            Once you understand these building blocks, you can decode thousands of medical terms. \
            Prefixes modify the meaning — 'hyper-' means excessive, 'hypo-' means deficient. \
            Roots identify the body part — 'cardi/o' for heart, 'nephr/o' for kidney. \
            Suffixes indicate the condition or procedure — '-itis' for inflammation, '-osis' for condition. \
            Let's practice: 'Hepatomegaly' — 'hepat/o' means liver, '-megaly' means enlargement. \
            So hepatomegaly is an enlarged liver. See how logical it becomes? \
            Keep practicing and these terms will become second nature to you.
            """
    }
}

enum AIVideoError: Error, LocalizedError {
    case generationFailed
    case timeout
    case noAvatarsAvailable
    case scriptGenerationFailed

    var errorDescription: String? {
        switch self {
        case .generationFailed: return "Video generation failed. Please try again."
        case .timeout: return "Video generation timed out."
        case .noAvatarsAvailable: return "No AI tutors available at the moment."
        case .scriptGenerationFailed: return "Could not generate teaching script."
        }
    }
}
