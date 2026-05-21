import SwiftUI
import AVKit

struct CollectionGalleryView: View {
    @State private var viewModel = CollectionGalleryViewModel()
    @State private var showingStudio = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    heroSection
                    if !viewModel.recentCreations.isEmpty {
                        recentCreationsSection
                    }
                    filterBar
                    galleryGrid
                    if viewModel.filteredArtworks.isEmpty {
                        emptyState
                    }
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.top, AppSpacing.md)
                .padding(.bottom, AppSpacing.xxl)
            }
            .background(AppColor.background)
            .navigationTitle("Collection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if AppState.shared.currentUserRole == .administrator || AppState.shared.currentUserRole == .superAdmin {
                        Button {
                            showingStudio = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(AppColor.diamondPowerGradient)
                                .font(.title3)
                                .shadow(color: AppColor.diamond.opacity(0.4), radius: 4)
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $showingStudio) {
                GenerationStudioView()
            }
            .sheet(item: $viewModel.selectedArtwork) { artwork in
                ArtworkDetailSheet(
                    artwork: artwork,
                    onToggleFavorite: { viewModel.toggleFavorite(artwork) },
                    onDelete: { viewModel.deleteArtwork(artwork) }
                )
            }
            .preferredColorScheme(.dark)
            .task { await viewModel.load() }
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: AppSpacing.sm) {
            HStack(spacing: AppSpacing.sm) {
                StatTile(
                    title: "Artworks",
                    value: "\(viewModel.totalCount)",
                    icon: "photo.on.rectangle.angled",
                    color: AppColor.diamond
                )
                StatTile(
                    title: "Videos",
                    value: "\(viewModel.videoCount)",
                    icon: "film",
                    color: AppColor.gold
                )
                StatTile(
                    title: "Favorites",
                    value: "\(viewModel.favoriteCount)",
                    icon: "heart.fill",
                    color: AppColor.streakOrange
                )
            }
        }
    }

    // MARK: - Recent Creations Carousel

    private var isCreator: Bool {
        let role = AppState.shared.currentUserRole
        return role == .administrator || role == .superAdmin
    }

    private var recentCreationsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(title: "Your Creations")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.sm) {
                    if isCreator {
                        createNewCard
                    }
                    ForEach(viewModel.recentCreations) { artwork in
                        recentCreationCard(artwork)
                    }
                }
            }
        }
    }

    private var createNewCard: some View {
        Button {
            showingStudio = true
        } label: {
            VStack(spacing: AppSpacing.xs) {
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .fill(
                        LinearGradient(
                            colors: [AppColor.diamond.opacity(0.12), AppColor.surfaceElevated],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 140, height: 140)
                    .overlay {
                        VStack(spacing: AppSpacing.xs) {
                            Image(systemName: "wand.and.stars")
                                .font(.system(size: 28))
                                .foregroundStyle(AppColor.diamondPowerGradient)
                                .shadow(color: AppColor.diamond.opacity(0.5), radius: 6)
                            Text("Generate New")
                                .font(AppTypography.caption1)
                                .fontWeight(.semibold)
                                .foregroundColor(AppColor.diamond)
                        }
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.md)
                            .strokeBorder(AppColor.diamond.opacity(0.3), style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                    )
            }
        }
    }

    private func recentCreationCard(_ artwork: GeneratedArtwork) -> some View {
        Button {
            viewModel.selectedArtwork = artwork
        } label: {
            ZStack(alignment: .bottomLeading) {
                AsyncImage(url: artwork.thumbnailURL ?? artwork.mediaURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        AppColor.surfaceElevated
                            .overlay {
                                Image(systemName: artwork.mediaType.icon)
                                    .font(.title2)
                                    .foregroundColor(AppColor.textTertiary)
                            }
                    }
                }
                .frame(width: 140, height: 140)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))

                LinearGradient(colors: [.clear, .black.opacity(0.7)], startPoint: .center, endPoint: .bottom)
                    .frame(height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))

                HStack(spacing: AppSpacing.xxs) {
                    if artwork.isVideo {
                        Image(systemName: "play.circle.fill")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    if artwork.isFavorite {
                        Image(systemName: "heart.fill")
                            .font(.caption)
                            .foregroundColor(AppColor.streakOrange)
                    }
                    Text(artwork.formattedDate)
                        .font(AppTypography.caption2)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(AppSpacing.xs)
            }
            .frame(width: 140, height: 140)
        }
    }

    // MARK: - Filter

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.xs) {
                filterChip("All", filter: .all)
                filterChip("Images", filter: .images)
                filterChip("Videos", filter: .videos)
                filterChip("Favorites", filter: .favorites)
            }
        }
    }

    private func filterChip(_ title: String, filter: CollectionGalleryViewModel.Filter) -> some View {
        let isActive = viewModel.activeFilter == filter
        return Button {
            withAnimation(.spring(duration: 0.25)) { viewModel.activeFilter = filter }
        } label: {
            Text(title)
                .font(AppTypography.subheadline)
                .fontWeight(isActive ? .bold : .medium)
                .foregroundColor(isActive ? AppColor.primaryDark : AppColor.textSecondary)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.xs)
                .background(isActive ? AppColor.diamond : AppColor.surfaceElevated)
                .clipShape(Capsule())
                .shadow(color: isActive ? AppColor.diamond.opacity(0.3) : .clear, radius: 6, y: 2)
        }
    }

    // MARK: - Gallery Grid

    private var galleryGrid: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 160), spacing: AppSpacing.sm)],
            spacing: AppSpacing.sm
        ) {
            ForEach(viewModel.filteredArtworks) { artwork in
                galleryCell(artwork)
            }
        }
    }

    private func galleryCell(_ artwork: GeneratedArtwork) -> some View {
        Button {
            viewModel.selectedArtwork = artwork
        } label: {
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: artwork.thumbnailURL ?? artwork.mediaURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        AppColor.surfaceElevated
                            .overlay {
                                ProgressView()
                                    .tint(AppColor.textTertiary)
                            }
                    }
                }
                .frame(minHeight: 160)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))

                HStack(spacing: 4) {
                    if artwork.isVideo {
                        Image(systemName: "play.circle.fill")
                            .font(.caption)
                            .foregroundColor(.white)
                            .shadow(radius: 2)
                    }
                    if artwork.isFavorite {
                        Image(systemName: "heart.fill")
                            .font(.caption)
                            .foregroundColor(AppColor.streakOrange)
                            .shadow(radius: 2)
                    }
                }
                .padding(AppSpacing.xs)
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: AppSpacing.lg) {
            ZStack {
                Circle()
                    .fill(AppColor.diamond.opacity(0.08))
                    .frame(width: 110, height: 110)
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 50))
                    .foregroundStyle(AppColor.diamondPowerGradient)
                    .shadow(color: AppColor.diamond.opacity(0.4), radius: 10)
            }

            Text("No Artworks Yet")
                .font(AppTypography.title2)
                .foregroundColor(AppColor.textPrimary)

            Text("Artworks created by the administrator\nwill appear here automatically.")
                .font(AppTypography.subheadline)
                .foregroundColor(AppColor.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.xxl)
    }
}

// MARK: - Detail Sheet

struct ArtworkDetailSheet: View {
    let artwork: GeneratedArtwork
    let onToggleFavorite: () -> Void
    let onDelete: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirmation = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    mediaView
                    infoSection
                    actionButtons
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
            .navigationTitle(artwork.isVideo ? "Video Detail" : "Artwork Detail")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Delete Artwork?", isPresented: $showDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    onDelete()
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This action cannot be undone.")
            }
        }
    }

    @ViewBuilder
    private var mediaView: some View {
        if artwork.isVideo, let url = artwork.mediaURL {
            VideoPlayer(player: AVPlayer(url: url))
                .aspectRatio(CGFloat(artwork.width) / CGFloat(artwork.height), contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
                .padding(.horizontal, AppSpacing.md)
        } else {
            AsyncImage(url: artwork.mediaURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
                default:
                    RoundedRectangle(cornerRadius: AppRadius.lg)
                        .fill(AppColor.surfaceElevated)
                        .frame(height: 300)
                        .overlay {
                            ProgressView()
                        }
                }
            }
            .padding(.horizontal, AppSpacing.md)
        }
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
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
                infoPill("Model", artwork.modelName.components(separatedBy: "/").last ?? artwork.modelName)
                infoPill("Size", artwork.aspectRatioLabel)
                if let dur = artwork.durationSeconds {
                    infoPill("Duration", "\(dur)s")
                }
                if let seed = artwork.seed {
                    infoPill("Seed", "\(seed)")
                }
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

            Text("Created \(artwork.formattedDate) via \(artwork.provider)")
                .font(AppTypography.caption2)
                .foregroundColor(AppColor.textTertiary)
        }
        .padding(.horizontal, AppSpacing.md)
    }

    private func infoPill(_ label: String, _ value: String) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(AppTypography.caption2)
                .foregroundColor(AppColor.textTertiary)
            Text(value)
                .font(AppTypography.caption1)
                .foregroundColor(AppColor.textSecondary)
        }
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, AppSpacing.xs)
        .background(AppColor.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm))
    }

    private var actionButtons: some View {
        HStack(spacing: AppSpacing.md) {
            Button {
                onToggleFavorite()
            } label: {
                HStack(spacing: AppSpacing.xxs) {
                    Image(systemName: artwork.isFavorite ? "heart.fill" : "heart")
                    Text(artwork.isFavorite ? "Unfavorite" : "Favorite")
                }
                .font(AppTypography.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.md)
                .background(AppColor.surfaceElevated)
                .foregroundColor(artwork.isFavorite ? AppColor.streakOrange : AppColor.textSecondary)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
            }

            Button {
                showDeleteConfirmation = true
            } label: {
                HStack(spacing: AppSpacing.xxs) {
                    Image(systemName: "trash")
                    Text("Delete")
                }
                .font(AppTypography.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.md)
                .background(AppColor.error.opacity(0.1))
                .foregroundColor(AppColor.error)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
            }
        }
        .padding(.horizontal, AppSpacing.md)
    }
}

// MARK: - View Model

@MainActor
@Observable
final class CollectionGalleryViewModel {
    enum Filter: String, CaseIterable {
        case all, images, videos, favorites
    }

    var activeFilter: Filter = .all
    var selectedArtwork: GeneratedArtwork?

    private let store = CollectionStore.shared

    var totalCount: Int { store.artworks.count }
    var videoCount: Int { store.videos.count }
    var favoriteCount: Int { store.favorites.count }
    var recentCreations: [GeneratedArtwork] { store.recentCreations }

    var filteredArtworks: [GeneratedArtwork] {
        switch activeFilter {
        case .all: return store.artworks
        case .images: return store.images
        case .videos: return store.videos
        case .favorites: return store.favorites
        }
    }

    func load() async {
        await store.loadCollection()
    }

    func toggleFavorite(_ artwork: GeneratedArtwork) {
        store.toggleFavorite(artwork)
    }

    func deleteArtwork(_ artwork: GeneratedArtwork) {
        store.deleteArtwork(artwork)
    }
}

#Preview {
    CollectionGalleryView()
}
