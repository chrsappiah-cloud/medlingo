import Testing
import Foundation
@testable import medlingo

@MainActor
struct CollectionStoreTests {
    var networkMock: MockNetworkClient
    var sut: CollectionStore

    init() {
        networkMock = MockNetworkClient()
        sut = CollectionStore(networkClient: networkMock)
        sut.resetForTesting()
    }

    @Test func artworks_startsEmpty() {
        sut.resetForTesting()
        #expect(sut.artworks.isEmpty)
    }

    @Test func transmitFromGeneration_appendsArtwork() {
        sut.resetForTesting()
        let artwork = CollectionStore.sampleArtworks().first!

        sut.transmitFromGeneration(artwork)

        #expect(sut.artworks.count == 1)
        #expect(sut.artworks.first?.id == artwork.id)
    }

    @Test func transmitFromGeneration_doesNotDuplicate() {
        sut.resetForTesting()
        let artwork = CollectionStore.sampleArtworks().first!
        sut.transmitFromGeneration(artwork)
        sut.transmitFromGeneration(artwork)

        #expect(sut.artworks.count == 1)
    }

    @Test func toggleFavorite_flipsIsFavorite() {
        sut.resetForTesting()
        let artwork = CollectionStore.sampleArtworks().first!
        let wasFavorite = artwork.isFavorite
        sut.transmitFromGeneration(artwork)

        sut.toggleFavorite(artwork)

        #expect(sut.artworks.first?.isFavorite == !wasFavorite)
    }

    @Test func toggleFavorite_twice_returnsToOriginal() {
        sut.resetForTesting()
        let artwork = CollectionStore.sampleArtworks().first!
        sut.transmitFromGeneration(artwork)

        sut.toggleFavorite(sut.artworks.first!)
        let afterFirstToggle = sut.artworks.first?.isFavorite
        sut.toggleFavorite(sut.artworks.first!)

        #expect(sut.artworks.first?.isFavorite != afterFirstToggle)
    }

    @Test func deleteArtwork_removesFromArray() {
        sut.resetForTesting()
        let artwork = CollectionStore.sampleArtworks().first!
        sut.transmitFromGeneration(artwork)

        sut.deleteArtwork(artwork)

        #expect(sut.artworks.isEmpty)
    }

    @Test func favorites_filterReturnsOnlyFavorites() {
        sut.resetForTesting()
        let samples = CollectionStore.sampleArtworks()
        for artwork in samples {
            sut.transmitFromGeneration(artwork)
        }

        #expect(sut.favorites.allSatisfy { $0.isFavorite })
    }

    @Test func images_filterReturnsOnlyImages() {
        sut.resetForTesting()
        let samples = CollectionStore.sampleArtworks()
        for artwork in samples {
            sut.transmitFromGeneration(artwork)
        }

        #expect(sut.images.allSatisfy { $0.mediaType == .image })
    }

    @Test func videos_filterReturnsOnlyVideos() {
        sut.resetForTesting()
        let samples = CollectionStore.sampleArtworks()
        for artwork in samples {
            sut.transmitFromGeneration(artwork)
        }

        #expect(sut.videos.allSatisfy { $0.mediaType == .video })
    }

    @Test func recentCreations_returnsUpTo10MostRecent() {
        sut.resetForTesting()
        let samples = CollectionStore.sampleArtworks()
        for artwork in samples {
            sut.transmitFromGeneration(artwork)
        }

        #expect(sut.recentCreations.count <= 10)
        #expect(sut.recentCreations == sut.artworks.sorted { $0.createdAt > $1.createdAt }.prefix(10).map { $0 })
    }

    @Test func artworksWithTag_returnsFilteredResults() {
        sut.resetForTesting()
        let samples = CollectionStore.sampleArtworks()
        for artwork in samples {
            sut.transmitFromGeneration(artwork)
        }

        let heartArtworks = sut.artworks(withTag: "heart")
        #expect(heartArtworks.allSatisfy { $0.tags.contains("heart") })
    }

    @Test func allTags_returnsUniqueSortedTags() {
        sut.resetForTesting()
        let samples = CollectionStore.sampleArtworks()
        for artwork in samples {
            sut.transmitFromGeneration(artwork)
        }

        #expect(!sut.allTags.isEmpty)
        #expect(sut.allTags == Array(Set(sut.allTags)).sorted())
    }

    @Test func sampleArtworks_returns4Artworks() {
        #expect(CollectionStore.sampleArtworks().count == 4)
    }

    @Test func sampleArtworks_includesImageAndVideoTypes() {
        let samples = CollectionStore.sampleArtworks()
        #expect(samples.contains(where: { $0.mediaType == .image }))
        #expect(samples.contains(where: { $0.mediaType == .video }))
    }

    @Test func computedProperties_artworkIsVideo() {
        let image = CollectionStore.sampleArtworks().first { $0.mediaType == .image }!
        let video = CollectionStore.sampleArtworks().first { $0.mediaType == .video }!

        #expect(image.isVideo == false)
        #expect(video.isVideo == true)
    }

    @Test func aspectRatioLabel_formatsCorrectly() {
        let artwork = GeneratedArtwork(id: UUID(), ownerID: UUID(), prompt: "test", negativePrompt: nil, mediaType: .image, status: .completed, mediaURL: nil, thumbnailURL: nil, provider: "test", modelName: "test", width: 1920, height: 1080, durationSeconds: nil, seed: nil, createdAt: Date(), completedAt: nil, isFavorite: false, tags: [])

        #expect(artwork.aspectRatioLabel == "1920x1080")
    }
}
