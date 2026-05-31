import Foundation

/// Manages the user's generated artwork collection with Supabase persistence
/// and local caching for offline access.
@MainActor
@Observable
final class CollectionStore {
    static let shared = CollectionStore()

    private(set) var artworks: [GeneratedArtwork] = []
    private(set) var isLoading = false
    private(set) var lastError: String?

    var favorites: [GeneratedArtwork] { artworks.filter(\.isFavorite) }
    var images: [GeneratedArtwork] { artworks.filter { $0.mediaType == .image } }
    var videos: [GeneratedArtwork] { artworks.filter { $0.mediaType == .video } }
    var recentCreations: [GeneratedArtwork] {
        Array(artworks.sorted { $0.createdAt > $1.createdAt }.prefix(10))
    }

    private let networkClient: NetworkClientProtocol
    private let cacheKey = "collection_artworks_cache"
    private var isDemo: Bool { !SupabaseManager.shared.isConfigured }

    init(networkClient: NetworkClientProtocol? = nil) {
        self.networkClient = networkClient ?? SupabaseManager.shared.networkClient
        loadFromCache()
    }

    // MARK: - Auto-Transmission from Generation

    /// Called immediately after AI generation completes to auto-insert into the collection.
    func transmitFromGeneration(_ artwork: GeneratedArtwork) {
        if !artworks.contains(where: { $0.id == artwork.id }) {
            artworks.insert(artwork, at: 0)
            saveToCache()
        }

        guard !isDemo else { return }
        Task {
            do {
                try await persistToSupabase(artwork)
            } catch {
                lastError = "Sync failed: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - CRUD

    func loadCollection() async {
        isLoading = true
        defer { isLoading = false }

        guard !isDemo else {
            if artworks.isEmpty {
                artworks = Self.sampleArtworks()
                saveToCache()
            }
            return
        }

        do {
            let fetched: [GeneratedArtwork] = try await networkClient.request(Endpoint(
                path: "generated_artworks",
                queryItems: [
                    URLQueryItem(name: "order", value: "created_at.desc"),
                    URLQueryItem(name: "limit", value: "50")
                ]
            ))
            artworks = fetched
            saveToCache()
        } catch {
            lastError = error.localizedDescription
        }
    }

    func toggleFavorite(_ artwork: GeneratedArtwork) {
        guard let index = artworks.firstIndex(where: { $0.id == artwork.id }) else { return }
        let updated = GeneratedArtwork(
            id: artwork.id,
            ownerID: artwork.ownerID,
            prompt: artwork.prompt,
            negativePrompt: artwork.negativePrompt,
            mediaType: artwork.mediaType,
            status: artwork.status,
            mediaURL: artwork.mediaURL,
            thumbnailURL: artwork.thumbnailURL,
            provider: artwork.provider,
            modelName: artwork.modelName,
            width: artwork.width,
            height: artwork.height,
            durationSeconds: artwork.durationSeconds,
            seed: artwork.seed,
            createdAt: artwork.createdAt,
            completedAt: artwork.completedAt,
            isFavorite: !artwork.isFavorite,
            tags: artwork.tags
        )
        artworks[index] = updated
        saveToCache()

        guard !isDemo else { return }
        Task {
            try? await networkClient.request(Endpoint(
                path: "generated_artworks",
                method: .patch,
                body: try? JSONEncoder().encode(["is_favorite": updated.isFavorite]),
                queryItems: [URLQueryItem(name: "id", value: "eq.\(artwork.id.uuidString)")]
            ))
        }
    }

    func deleteArtwork(_ artwork: GeneratedArtwork) {
        artworks.removeAll { $0.id == artwork.id }
        saveToCache()

        guard !isDemo else { return }
        Task {
            try? await networkClient.request(Endpoint(
                path: "generated_artworks",
                method: .delete,
                queryItems: [URLQueryItem(name: "id", value: "eq.\(artwork.id.uuidString)")]
            ))
        }
    }

    func artworks(withTag tag: String) -> [GeneratedArtwork] {
        artworks.filter { $0.tags.contains(tag.lowercased()) }
    }

    var allTags: [String] {
        Array(Set(artworks.flatMap(\.tags))).sorted()
    }

    // MARK: - Supabase Persistence

    private func persistToSupabase(_ artwork: GeneratedArtwork) async throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let body = try encoder.encode(artwork)
        try await networkClient.request(Endpoint(
            path: "generated_artworks",
            method: .post,
            body: body
        ))
    }

    // MARK: - Local Cache

    private func saveToCache() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(artworks) else { return }
        UserDefaults.standard.set(data, forKey: cacheKey)
    }

    private func loadFromCache() {
        guard let data = UserDefaults.standard.data(forKey: cacheKey) else { return }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        artworks = (try? decoder.decode([GeneratedArtwork].self, from: data)) ?? []
    }

    func resetForTesting() {
        artworks = []
        isLoading = false
        lastError = nil
        UserDefaults.standard.removeObject(forKey: cacheKey)
    }

    // MARK: - Sample Data

    static func sampleArtworks() -> [GeneratedArtwork] {
        let now = Date()
        return [
            GeneratedArtwork(
                id: UUID(), ownerID: UUID(),
                prompt: "Human heart anatomical illustration, cross-section showing chambers and valves",
                negativePrompt: nil, mediaType: .image, status: .completed,
                mediaURL: URL(string: "https://picsum.photos/seed/heart/1024/1024"),
                thumbnailURL: URL(string: "https://picsum.photos/seed/heart/256/256"),
                provider: "stability-ai", modelName: "stability-ai/sdxl",
                width: 1024, height: 1024, durationSeconds: nil, seed: 42,
                createdAt: now.addingTimeInterval(-3600), completedAt: now.addingTimeInterval(-3500),
                isFavorite: true, tags: ["heart", "anatomy", "medical"]
            ),
            GeneratedArtwork(
                id: UUID(), ownerID: UUID(),
                prompt: "3D render of the human skeletal system, dynamic lighting, educational poster",
                negativePrompt: nil, mediaType: .image, status: .completed,
                mediaURL: URL(string: "https://picsum.photos/seed/skeleton/1024/1024"),
                thumbnailURL: URL(string: "https://picsum.photos/seed/skeleton/256/256"),
                provider: "black-forest-labs", modelName: "black-forest-labs/flux-1.1-pro",
                width: 1024, height: 1024, durationSeconds: nil, seed: 123,
                createdAt: now.addingTimeInterval(-7200), completedAt: now.addingTimeInterval(-7100),
                isFavorite: false, tags: ["skeleton", "bones", "anatomy", "render"]
            ),
            GeneratedArtwork(
                id: UUID(), ownerID: UUID(),
                prompt: "Neural pathway animation, synaptic transmission, cinematic microscopy",
                negativePrompt: nil, mediaType: .video, status: .completed,
                mediaURL: URL(string: "https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/720/Big_Buck_Bunny_720_10s_1MB.mp4"),
                thumbnailURL: URL(string: "https://picsum.photos/seed/neural/256/144"),
                provider: "tencent", modelName: "tencent/hunyuan-video",
                width: 1280, height: 720, durationSeconds: 10, seed: 456,
                createdAt: now.addingTimeInterval(-86400), completedAt: now.addingTimeInterval(-86300),
                isFavorite: true, tags: ["neural", "brain", "synapse", "animation"]
            ),
            GeneratedArtwork(
                id: UUID(), ownerID: UUID(),
                prompt: "Watercolor painting of red blood cells flowing through a vessel",
                negativePrompt: nil, mediaType: .image, status: .completed,
                mediaURL: URL(string: "https://picsum.photos/seed/blood/1024/768"),
                thumbnailURL: URL(string: "https://picsum.photos/seed/blood/256/192"),
                provider: "stability-ai", modelName: "stability-ai/sdxl",
                width: 1024, height: 768, durationSeconds: nil, seed: 789,
                createdAt: now.addingTimeInterval(-172800), completedAt: now.addingTimeInterval(-172700),
                isFavorite: false, tags: ["blood", "cells", "watercolor", "vessel"]
            ),
        ]
    }
}
