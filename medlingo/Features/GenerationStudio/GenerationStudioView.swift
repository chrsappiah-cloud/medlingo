import SwiftUI
import AVKit

struct GenerationStudioView: View {
    @State private var viewModel = GenerationStudioViewModel()
    @Environment(\.dismiss) private var dismiss

    private var isCreator: Bool {
        let role = AppState.shared.currentUserRole
        return role == .administrator || role == .superAdmin
    }

    var body: some View {
        NavigationStack {
            Group {
                if isCreator {
                    studioContent
                } else {
                    lockedView
                }
            }
            .background(AppColor.background)
            .navigationTitle("Generation Studio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .preferredColorScheme(.dark)
        }
    }

    private var lockedView: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()

            ZStack {
                Circle()
                    .fill(AppColor.surfaceElevated)
                    .frame(width: 120, height: 120)
                    .overlay(
                        Circle()
                            .stroke(AppColor.diamond.opacity(0.3), lineWidth: 2)
                    )
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(AppColor.diamondPowerGradient)
                    .shadow(color: AppColor.diamond.opacity(0.4), radius: 12)
            }

            Text("Creator Access Only")
                .font(AppTypography.title2)
                .foregroundColor(AppColor.textPrimary)

            Text("The AI Generation Studio is available\nto administrators and creators.")
                .font(AppTypography.body)
                .foregroundColor(AppColor.textSecondary)
                .multilineTextAlignment(.center)

            Text("Generated artworks from creators\nwill appear in the Collection tab.")
                .font(AppTypography.subheadline)
                .foregroundColor(AppColor.textTertiary)
                .multilineTextAlignment(.center)
                .padding(.top, AppSpacing.xs)

            Spacer()
        }
        .padding(AppSpacing.xl)
    }

    private var studioContent: some View {
        @Bindable var viewModel = viewModel

        return ScrollView {
            VStack(spacing: AppSpacing.lg) {
                headerSection
                mediaTypePicker
                promptSection
                modelPicker
                styleGrid
                dimensionPicker
                generateButton
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.top, AppSpacing.md)
            .padding(.bottom, AppSpacing.xxl)
        }
        .overlay {
            if viewModel.isGenerating {
                generatingOverlay
            }
        }
        .sheet(isPresented: $viewModel.showResultSheet) {
            if let artwork = viewModel.lastGenerated {
                ArtworkResultSheet(artwork: artwork)
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: AppSpacing.xs) {
            ZStack {
                Circle()
                    .fill(AppColor.diamond.opacity(0.08))
                    .frame(width: 80, height: 80)
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 36))
                    .foregroundStyle(AppColor.diamondPowerGradient)
                    .shadow(color: AppColor.diamond.opacity(0.5), radius: 10)
            }

            Text("Create with AI")
                .font(AppTypography.title1)
                .foregroundStyle(AppColor.diamondPowerGradient)

            Text("Generate medical art and educational videos using open-source AI models")
                .font(AppTypography.subheadline)
                .foregroundColor(AppColor.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, AppSpacing.sm)
    }

    // MARK: - Media Type

    private var mediaTypePicker: some View {
        HStack(spacing: AppSpacing.sm) {
            ForEach(ArtworkMediaType.allCases) { type in
                let isSelected = viewModel.selectedMediaType == type
                Button {
                    withAnimation(.spring(duration: 0.3)) {
                        viewModel.selectedMediaType = type
                        viewModel.updateModelSelection()
                    }
                } label: {
                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: type.icon)
                            .shadow(color: isSelected ? AppColor.diamond.opacity(0.6) : .clear, radius: 4)
                        Text(type.displayName)
                            .font(AppTypography.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.sm)
                    .background(isSelected ? AppColor.diamond.opacity(0.15) : AppColor.surfaceElevated)
                    .foregroundColor(isSelected ? AppColor.diamond : AppColor.textSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.md)
                            .stroke(isSelected ? AppColor.diamond.opacity(0.5) : Color.clear, lineWidth: 1.5)
                    )
                    .shadow(color: isSelected ? AppColor.diamond.opacity(0.12) : .clear, radius: 8, y: 4)
                }
            }
        }
    }

    // MARK: - Prompt

    private var promptSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: "text.cursor")
                    .foregroundColor(AppColor.diamond)
                    .font(.subheadline)
                Text("Describe your creation")
                    .font(AppTypography.headline)
                    .foregroundColor(AppColor.textPrimary)
            }

            ZStack(alignment: .topLeading) {
                if viewModel.prompt.isEmpty {
                    Text("e.g. \"Detailed cross-section of the human heart showing all four chambers...\"")
                        .font(AppTypography.body)
                        .foregroundColor(AppColor.textTertiary)
                        .padding(.horizontal, AppSpacing.sm)
                        .padding(.vertical, AppSpacing.sm + 2)
                }

                TextEditor(text: $viewModel.prompt)
                    .font(AppTypography.body)
                    .foregroundColor(AppColor.textPrimary)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 100, maxHeight: 160)
                    .padding(.horizontal, AppSpacing.xxs)
                    .padding(.vertical, AppSpacing.xxs)
            }
            .background(AppColor.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .stroke(AppColor.diamond.opacity(0.2), lineWidth: 1)
            )

            HStack {
                Text("\(viewModel.prompt.count) characters")
                    .font(AppTypography.caption2)
                    .foregroundColor(AppColor.textTertiary)
                Spacer()
                Button {
                    viewModel.prompt = Self.promptSuggestions.randomElement() ?? ""
                } label: {
                    HStack(spacing: AppSpacing.xxs) {
                        Image(systemName: "dice.fill")
                        Text("Suggest")
                    }
                    .font(AppTypography.caption1)
                    .foregroundColor(AppColor.diamond)
                }
            }
        }
    }

    // MARK: - Model Picker

    private var modelPicker: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: "cpu.fill")
                    .foregroundColor(AppColor.diamond)
                    .font(.subheadline)
                Text("AI Model")
                    .font(AppTypography.headline)
                    .foregroundColor(AppColor.textPrimary)
            }

            ForEach(viewModel.filteredModels) { model in
                Button {
                    viewModel.selectedModel = model
                } label: {
                    HStack(spacing: AppSpacing.sm) {
                        Image(systemName: model.mediaType == .image ? "photo.fill" : "film")
                            .font(.title3)
                            .foregroundColor(viewModel.selectedModel?.id == model.id ? AppColor.gold : AppColor.textTertiary)
                            .frame(width: 36)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(model.name)
                                .font(AppTypography.subheadline)
                                .foregroundColor(AppColor.textPrimary)
                            Text(model.description)
                                .font(AppTypography.caption2)
                                .foregroundColor(AppColor.textSecondary)
                                .lineLimit(1)
                        }
                        Spacer()
                        Text(model.provider)
                            .font(AppTypography.caption2)
                            .foregroundColor(AppColor.textTertiary)
                            .padding(.horizontal, AppSpacing.xs)
                            .padding(.vertical, 2)
                            .background(AppColor.surfaceGlass)
                            .clipShape(Capsule())

                        if viewModel.selectedModel?.id == model.id {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(AppColor.gold)
                        }
                    }
                    .padding(AppSpacing.sm)
                    .background(viewModel.selectedModel?.id == model.id ? AppColor.gold.opacity(0.08) : AppColor.surface)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.md)
                            .stroke(viewModel.selectedModel?.id == model.id ? AppColor.gold.opacity(0.3) : Color.white.opacity(0.05), lineWidth: 1)
                    )
                }
            }
        }
    }

    // MARK: - Style Grid

    private var styleGrid: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: "paintpalette.fill")
                    .foregroundColor(AppColor.diamond)
                    .font(.subheadline)
                Text("Style Preset")
                    .font(AppTypography.headline)
                    .foregroundColor(AppColor.textPrimary)
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: AppSpacing.xs)], spacing: AppSpacing.xs) {
                ForEach(InVideoAIService.stylePresets) { preset in
                    Button {
                        viewModel.selectedStyle = preset
                    } label: {
                        VStack(spacing: AppSpacing.xxs) {
                            Image(systemName: preset.icon)
                                .font(.title3)
                                .foregroundColor(viewModel.selectedStyle?.id == preset.id ? AppColor.gold : AppColor.textTertiary)
                            Text(preset.name)
                                .font(AppTypography.caption1)
                                .foregroundColor(viewModel.selectedStyle?.id == preset.id ? AppColor.textPrimary : AppColor.textSecondary)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.sm)
                        .background(viewModel.selectedStyle?.id == preset.id ? AppColor.gold.opacity(0.12) : AppColor.surfaceElevated)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppRadius.sm)
                                .stroke(viewModel.selectedStyle?.id == preset.id ? AppColor.gold.opacity(0.4) : Color.clear, lineWidth: 1)
                        )
                    }
                }
            }
        }
    }

    // MARK: - Dimensions

    private var dimensionPicker: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: "aspectratio.fill")
                    .foregroundColor(AppColor.diamond)
                    .font(.subheadline)
                Text("Dimensions")
                    .font(AppTypography.headline)
                    .foregroundColor(AppColor.textPrimary)
            }

            HStack(spacing: AppSpacing.sm) {
                ForEach(viewModel.dimensionOptions, id: \.label) { option in
                    Button {
                        viewModel.selectedWidth = option.width
                        viewModel.selectedHeight = option.height
                    } label: {
                        VStack(spacing: 2) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(viewModel.selectedWidth == option.width && viewModel.selectedHeight == option.height ? AppColor.gold : AppColor.textTertiary)
                                .aspectRatio(CGFloat(option.width) / CGFloat(option.height), contentMode: .fit)
                                .frame(height: 24)
                            Text(option.label)
                                .font(AppTypography.caption2)
                                .foregroundColor(viewModel.selectedWidth == option.width ? AppColor.textPrimary : AppColor.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.xs)
                        .background(viewModel.selectedWidth == option.width && viewModel.selectedHeight == option.height ? AppColor.gold.opacity(0.1) : AppColor.surfaceElevated)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm))
                    }
                }
            }
        }
    }

    // MARK: - Generate

    private var generateButton: some View {
        PrimaryButton(
            title: "Generate \(viewModel.selectedMediaType.displayName)",
            action: {
                Task { await viewModel.generate() }
            },
            isLoading: viewModel.isGenerating
        )
        .accessibilityIdentifier("generate-artwork-button")
        .disabled(viewModel.prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        .opacity(viewModel.prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
    }

    // MARK: - Generating Overlay

    private var generatingOverlay: some View {
        ZStack {
            Color.black.opacity(0.75)
                .ignoresSafeArea()

            VStack(spacing: AppSpacing.lg) {
                ZStack {
                    Circle()
                        .stroke(AppColor.diamond.opacity(0.2), lineWidth: 4)
                        .frame(width: 100, height: 100)
                    Circle()
                        .trim(from: 0, to: viewModel.generationProgress)
                        .stroke(
                            AngularGradient(
                                colors: [AppColor.diamond, AppColor.gold, AppColor.diamond],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.5), value: viewModel.generationProgress)

                    Image(systemName: viewModel.selectedMediaType == .video ? "film" : "photo.artframe")
                        .font(.system(size: 32))
                        .foregroundStyle(AppColor.diamondGradient)
                }

                Text(viewModel.generationStatusMessage)
                    .font(AppTypography.headline)
                    .foregroundColor(AppColor.textPrimary)
                    .multilineTextAlignment(.center)

                Text("\(Int(viewModel.generationProgress * 100))%")
                    .font(AppTypography.statValue)
                    .foregroundStyle(AppColor.goldGradient)

                Button("Cancel") {
                    viewModel.cancelGeneration()
                }
                .font(AppTypography.subheadline)
                .foregroundColor(AppColor.textTertiary)
            }
            .padding(AppSpacing.xl)
        }
        .transition(.opacity)
    }

    static let promptSuggestions = [
        "Detailed anatomical illustration of the human brain showing the cerebral cortex, cerebellum, and brain stem with labeled regions",
        "Cross-section of a healthy lung showing alveoli, bronchioles, and capillary network in medical illustration style",
        "3D render of DNA double helix unwinding during replication with polymerase enzymes visible",
        "Cinematic view of white blood cells attacking a pathogen, microscopic photography style",
        "Watercolor painting of the human cardiovascular system showing arterial and venous circulation",
        "Educational diagram of the nephron structure in the kidney with glomerulus and tubule system",
        "Animated visualization of an action potential traveling along a neuron axon",
        "Medical illustration of the musculoskeletal system of the human hand showing tendons and bones",
    ]
}

// MARK: - Result Sheet

struct ArtworkResultSheet: View {
    let artwork: GeneratedArtwork
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    if artwork.isVideo {
                        if let url = artwork.mediaURL {
                            VideoPlayer(player: AVPlayer(url: url))
                                .aspectRatio(CGFloat(artwork.width) / CGFloat(artwork.height), contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
                        }
                    } else {
                        AsyncImage(url: artwork.mediaURL) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
                            case .failure:
                                placeholderImage
                            case .empty:
                                ProgressView()
                                    .frame(height: 300)
                            @unknown default:
                                placeholderImage
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(AppColor.emerald)
                            Text("Added to Your Collection")
                                .font(AppTypography.headline)
                                .foregroundColor(AppColor.emerald)
                                .accessibilityIdentifier("generation-result-success")
                        }

                        AppCard {
                            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                Text("Prompt")
                                    .font(AppTypography.caption1)
                                    .foregroundColor(AppColor.textTertiary)
                                Text(artwork.prompt)
                                    .font(AppTypography.body)
                                    .foregroundColor(AppColor.textPrimary)
                            }
                        }

                        HStack(spacing: AppSpacing.sm) {
                            detailPill(icon: artwork.mediaType.icon, text: artwork.mediaType.displayName)
                            detailPill(icon: "aspectratio", text: artwork.aspectRatioLabel)
                            detailPill(icon: "cpu", text: artwork.modelName.components(separatedBy: "/").last ?? artwork.modelName)
                        }

                        if !artwork.tags.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: AppSpacing.xxs) {
                                    ForEach(artwork.tags, id: \.self) { tag in
                                        Text("#\(tag)")
                                            .font(AppTypography.caption2)
                                            .foregroundColor(AppColor.diamond)
                                            .padding(.horizontal, AppSpacing.xs)
                                            .padding(.vertical, 3)
                                            .background(AppColor.diamond.opacity(0.1))
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, AppSpacing.md)
                }
                .padding(.vertical, AppSpacing.md)
            }
            .background(AppColor.background)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(AppColor.gold)
                }
            }
            .navigationTitle("Generation Complete")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var placeholderImage: some View {
        RoundedRectangle(cornerRadius: AppRadius.lg)
            .fill(AppColor.surfaceElevated)
            .frame(height: 300)
            .overlay {
                Image(systemName: "photo")
                    .font(.system(size: 48))
                    .foregroundColor(AppColor.textTertiary)
            }
    }

    private func detailPill(icon: String, text: String) -> some View {
        HStack(spacing: AppSpacing.xxs) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(AppTypography.caption2)
        }
        .foregroundColor(AppColor.textSecondary)
        .padding(.horizontal, AppSpacing.xs)
        .padding(.vertical, 4)
        .background(AppColor.surfaceElevated)
        .clipShape(Capsule())
    }
}

// MARK: - View Model

@MainActor
@Observable
final class GenerationStudioViewModel {
    var prompt = ""
    var selectedMediaType: ArtworkMediaType = .image
    var selectedModel: InVideoAIService.AIModel?
    var selectedStyle: InVideoAIService.StylePreset?
    var selectedWidth = 1024
    var selectedHeight = 1024
    var isGenerating = false
    var generationProgress: Double = 0
    var generationStatusMessage = "Preparing..."
    var showResultSheet = false
    var lastGenerated: GeneratedArtwork?
    var errorMessage: String?

    private let service = InVideoAIService.shared
    private let collectionStore = CollectionStore.shared
    private var generationTask: Task<Void, Never>?

    struct DimensionOption {
        let label: String
        let width: Int
        let height: Int
    }

    var filteredModels: [InVideoAIService.AIModel] {
        service.models(for: selectedMediaType)
    }

    var dimensionOptions: [DimensionOption] {
        if selectedMediaType == .video {
            return [
                DimensionOption(label: "16:9", width: 1280, height: 720),
                DimensionOption(label: "9:16", width: 720, height: 1280),
                DimensionOption(label: "1:1", width: 720, height: 720),
            ]
        }
        return [
            DimensionOption(label: "1:1", width: 1024, height: 1024),
            DimensionOption(label: "16:9", width: 1536, height: 864),
            DimensionOption(label: "9:16", width: 864, height: 1536),
            DimensionOption(label: "4:3", width: 1024, height: 768),
        ]
    }

    init() {
        if AppLaunchConfiguration.shared.forcesDemoAIGeneration {
            selectedMediaType = .video
            prompt = "Detailed anatomical illustration of the human heart showing all four chambers"
        }
        updateModelSelection()
    }

    func updateModelSelection() {
        selectedModel = filteredModels.first
        let dims = dimensionOptions.first
        selectedWidth = dims?.width ?? 1024
        selectedHeight = dims?.height ?? 1024
    }

    func generate() async {
        guard !prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        isGenerating = true
        generationProgress = 0
        showResultSheet = false
        errorMessage = nil

        let enhancedPrompt = service.enhancePrompt(prompt, style: selectedStyle)

        let request = ArtworkGenerationRequest(
            prompt: enhancedPrompt,
            negativePrompt: "blurry, low quality, distorted, deformed, ugly, watermark, text overlay",
            mediaType: selectedMediaType,
            width: selectedWidth,
            height: selectedHeight,
            durationSeconds: selectedMediaType == .video ? 10 : nil,
            model: selectedModel?.id ?? Config.defaultImageModel,
            seed: nil,
            stylePreset: selectedStyle?.id
        )

        generationTask = Task {
            do {
                let artwork = try await service.generateAndAwait(request: request) { [weak self] progress, message in
                    Task { @MainActor in
                        self?.generationProgress = progress
                        self?.generationStatusMessage = message
                    }
                }

                lastGenerated = artwork
                collectionStore.transmitFromGeneration(artwork)
                isGenerating = false
                showResultSheet = true

            } catch is CancellationError {
                isGenerating = false
            } catch {
                errorMessage = error.localizedDescription
                isGenerating = false
            }
        }

        await generationTask?.value
    }

    func cancelGeneration() {
        generationTask?.cancel()
        generationTask = nil
        isGenerating = false
    }
}

#Preview {
    GenerationStudioView()
}
