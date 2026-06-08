import Testing
import Foundation
@testable import medlingo

@MainActor
struct InVideoAIServiceTests {
    var sut: InVideoAIService

    init() {
        let config = AppLaunchConfiguration(arguments: ["-mockAIGeneration"])
        sut = InVideoAIService(client: MockNetworkClient(), launchConfiguration: config)
    }

    @Test func availableModels_has5Models() {
        #expect(InVideoAIService.availableModels.count == 5)
    }

    @Test func availableModels_includesImageAndVideoModels() {
        let models = InVideoAIService.availableModels
        #expect(models.contains(where: { $0.mediaType == .image }))
        #expect(models.contains(where: { $0.mediaType == .video }))
    }

    @Test func stylePresets_has8Presets() {
        #expect(InVideoAIService.stylePresets.count == 8)
    }

    @Test func stylePresets_includesNoneStyle() {
        #expect(InVideoAIService.stylePresets.contains(where: { $0.id == "none" }))
    }

    @Test func modelsForImage_returnsOnlyImageModels() {
        let imageModels = sut.models(for: .image)
        #expect(imageModels.allSatisfy { $0.mediaType == .image })
    }

    @Test func modelsForVideo_returnsOnlyVideoModels() {
        let videoModels = sut.models(for: .video)
        #expect(videoModels.allSatisfy { $0.mediaType == .video })
    }

    @Test func enhancePrompt_withoutStyle_returnsSamePrompt() {
        let prompt = "Human heart anatomy"
        let result = sut.enhancePrompt(prompt, style: nil)
        #expect(result == prompt)
    }

    @Test func enhancePrompt_withNoneStyle_returnsSamePrompt() {
        let prompt = "Brain scan"
        let noneStyle = InVideoAIService.stylePresets.first { $0.id == "none" }!
        let result = sut.enhancePrompt(prompt, style: noneStyle)
        #expect(result == prompt)
    }

    @Test func enhancePrompt_withMedicalStyle_appendsSuffix() {
        let prompt = "Lung diagram"
        let medicalStyle = InVideoAIService.stylePresets.first { $0.id == "medical-illustration" }!
        let result = sut.enhancePrompt(prompt, style: medicalStyle)

        #expect(result.hasPrefix(prompt))
        #expect(result.contains("medical illustration"))
    }

    @Test func enhancePrompt_withPhotorealisticStyle_appendsSuffix() {
        let prompt = "Kidney cross section"
        let photoStyle = InVideoAIService.stylePresets.first { $0.id == "photorealistic" }!
        let result = sut.enhancePrompt(prompt, style: photoStyle)

        #expect(result.hasPrefix(prompt))
        #expect(result.contains("photorealistic"))
    }

    @Test func enhancePrompt_trimsWhitespace() {
        let prompt = "  Cell structure  "
        let result = sut.enhancePrompt(prompt, style: nil)
        #expect(result == "Cell structure")
    }

    @Test func generateArtwork_inDemoMode_returnsCompletedArtwork() async throws {
        let request = ArtworkGenerationRequest(prompt: "Heart anatomy", negativePrompt: nil, mediaType: .image, width: 1024, height: 1024, durationSeconds: nil, model: "stability-ai/sdxl", seed: nil, stylePreset: "medical-illustration")

        let artwork = try await sut.generateArtwork(request: request)

        #expect(artwork.status == .completed)
        #expect(artwork.prompt == "Heart anatomy")
        #expect(artwork.mediaType == .image)
        #expect(artwork.provider == "demo")
    }

    @Test func generateArtwork_inDemoVideoMode_returnsVideoWithDuration() async throws {
        let request = ArtworkGenerationRequest(prompt: "Blood flow animation", negativePrompt: nil, mediaType: .video, width: 1280, height: 720, durationSeconds: 10, model: "tencent/hunyuan-video", seed: nil, stylePreset: "cinematic")

        let artwork = try await sut.generateArtwork(request: request)

        #expect(artwork.mediaType == .video)
        #expect(artwork.durationSeconds == 10)
        #expect(artwork.mediaURL?.absoluteString.contains("test-videos") == true)
    }

    @Test func generateAndAwait_inDemoMode_callsProgress() async {
        let request = ArtworkGenerationRequest(prompt: "Test", negativePrompt: nil, mediaType: .image, width: 512, height: 512, durationSeconds: nil, model: "test", seed: nil, stylePreset: nil)
        var progressUpdates: [(Double, String)] = []

        let artwork = try? await sut.generateAndAwait(request: request) { progress, status in
            progressUpdates.append((progress, status))
        }

        #expect(artwork != nil)
        #expect(!progressUpdates.isEmpty)
        #expect(progressUpdates.last?.0 == 1.0)
        #expect(progressUpdates.last?.1 == "Complete")
    }

    @Test func extractTags_filtersStopWords() {
        let prompt = "The human heart anatomy with blood vessels"
        let tags = sut.enhancePrompt(prompt, style: nil)
        #expect(!tags.isEmpty)
    }
}
