import SwiftUI

struct ChapterListView: View {
    @State private var viewModel = ChapterListViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: AppSpacing.md) {
                    ForEach(Array(viewModel.chapters.enumerated()), id: \.element.id) { index, chapter in
                        NavigationLink(destination: ChapterDetailView(chapter: chapter, colorIndex: index)) {
                            StageRowCard(chapter: chapter, colorIndex: index, progress: viewModel.progress(for: chapter))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(AppSpacing.md)
            }
            .background(AppColor.background)
            .navigationTitle("Stages")
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }
}

struct StageRowCard: View {
    let chapter: Chapter
    let colorIndex: Int
    let progress: Double

    private var stageColor: Color {
        AppColor.stageColors[colorIndex % AppColor.stageColors.count]
    }

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .fill(
                        RadialGradient(
                            colors: [stageColor.opacity(0.3), stageColor.opacity(0.05)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 40
                        )
                    )
                    .frame(width: 56, height: 56)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.md)
                            .stroke(stageColor.opacity(0.5), lineWidth: 1)
                    )
                VStack(spacing: 0) {
                    Text("STAGE")
                        .font(.system(size: 8, weight: .bold, design: .rounded))
                        .foregroundColor(stageColor.opacity(0.7))
                    Text("\(chapter.number)")
                        .font(AppTypography.title2)
                        .foregroundColor(stageColor)
                        .shadow(color: stageColor.opacity(0.5), radius: 2)
                }
            }

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(chapter.title)
                    .font(AppTypography.headline)
                    .foregroundColor(AppColor.textPrimary)
                Text(chapter.summary)
                    .font(AppTypography.subheadline)
                    .foregroundColor(AppColor.textSecondary)

                HStack(spacing: AppSpacing.xs) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(stageColor.opacity(0.15))
                                .frame(height: 6)
                            RoundedRectangle(cornerRadius: 3)
                                .fill(
                                    LinearGradient(
                                        colors: [stageColor, stageColor.opacity(0.7)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * progress, height: 6)
                                .shadow(color: stageColor.opacity(0.5), radius: 2)
                        }
                    }
                    .frame(height: 6)
                    Text("\(Int(progress * 100))%")
                        .font(AppTypography.caption2)
                        .foregroundColor(stageColor)
                        .frame(width: 32)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(AppColor.textTertiary)
                .font(.caption)
        }
        .padding(AppSpacing.md)
        .background(AppColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .stroke(
                    progress >= 1.0 ? stageColor.opacity(0.4) : Color.white.opacity(0.04),
                    lineWidth: 1
                )
        )
    }
}

@MainActor
@Observable
final class ChapterListViewModel {
    var chapters: [Chapter] = []
    var isLoading = false

    private var progressMap: [UUID: Double] = [:]

    init() {
        loadSampleData()
    }

    func progress(for chapter: Chapter) -> Double {
        progressMap[chapter.id] ?? 0
    }

    private func loadSampleData() {
        let sampleStages: [(String, String)] = [
            ("Word Parts & Foundations", "Prefixes, roots, suffixes, combining forms"),
            ("Body Organization", "Anatomical orientation and body systems"),
            ("Integumentary System", "Skin, hair, nails, and disorders"),
            ("Skeletal System", "Bones, joints, and conditions"),
            ("Muscular System", "Muscles, movement, disorders"),
            ("Nervous System", "Brain, spinal cord, nerves"),
            ("Special Senses", "Eyes, ears, taste, touch"),
            ("Endocrine System", "Hormones and glands"),
            ("Cardiovascular System", "Heart and blood vessels"),
            ("Lymphatic & Immunity", "Immune system and defenses"),
            ("Respiratory System", "Lungs and breathing"),
            ("Digestive System", "GI tract and organs"),
            ("Urinary System", "Kidneys and excretion"),
            ("Reproductive System", "Male and female anatomy"),
            ("Clinical Applications", "Cross-system review"),
        ]

        chapters = sampleStages.enumerated().map { index, data in
            let id = UUID()
            progressMap[id] = index < 2 ? Double.random(in: 0.5...1.0) : (index == 2 ? Double.random(in: 0.1...0.5) : 0)
            return Chapter(
                id: id,
                number: index + 1,
                title: data.0,
                summary: data.1,
                estimatedMinutes: Int.random(in: 45...90),
                coverArtURL: nil,
                accentColorHex: "",
                prerequisiteIDs: [],
                unlockRule: .free
            )
        }
    }
}

#Preview {
    ChapterListView()
}
