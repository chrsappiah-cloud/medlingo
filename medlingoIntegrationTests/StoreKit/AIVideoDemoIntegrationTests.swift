import Testing
@testable import medlingo

@MainActor
struct AIVideoDemoIntegrationTests {
    @Test func demoVideoGeneration_producesPlayableArtwork() async throws {
        let service = InVideoAIService(
            launchConfiguration: AppLaunchConfiguration(arguments: ["-mockAIGeneration"])
        )
        let request = ArtworkGenerationRequest(
            prompt: "Microscopic view of red blood cells in a capillary",
            negativePrompt: nil,
            mediaType: .video,
            width: 1280,
            height: 720,
            durationSeconds: 10,
            model: Config.defaultVideoModel,
            seed: nil,
            stylePreset: nil
        )

        let artwork = try await service.generateAndAwait(request: request) { _, _ in }

        #expect(artwork.mediaType == .video)
        #expect(artwork.status == .completed)
        #expect(artwork.mediaURL != nil)
    }
}
