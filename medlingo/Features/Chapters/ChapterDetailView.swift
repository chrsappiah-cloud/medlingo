import SwiftUI

struct ChapterDetailView: View {
    let chapter: Chapter
    let colorIndex: Int

    private var stageColor: Color {
        AppColor.stageColors[colorIndex % AppColor.stageColors.count]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                heroSection
                lessonRoadmap
                practiceSection
                tutorSupportSection
                glossaryPreview
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.bottom, AppSpacing.xxl)
        }
        .background(AppColor.background)
        .navigationTitle("Stage \(chapter.number)")
        .navigationBarTitleDisplayMode(.large)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .preferredColorScheme(.dark)
        .navigationDestination(for: NavigationRouter.Destination.self) { destination in
            routeDestination(destination)
        }
    }

    @ViewBuilder
    private func routeDestination(_ destination: NavigationRouter.Destination) -> some View {
        switch destination {
        case .lessonPlayer(let lessonID, let chapterID):
            let lessons = DataMiddleware.sampleLessons(for: chapterID)
            if let lesson = lessons.first(where: { $0.id == lessonID }) ?? lessons.first {
                LessonPlayerView(lesson: lesson, stageColor: stageColor)
            }
        case .flashcards:
            FlashcardsView()
        case .wordBuilder:
            WordBuilderView()
        case .labeling:
            LabelingView()
        case .quiz:
            QuizView(exercise: nil)
        case .caseStudy:
            CaseStudyView()
        case .bookSession:
            TutorDiscoveryView()
        default:
            Text("Coming Soon")
        }
    }

    private var heroSection: some View {
        VStack(spacing: AppSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: AppRadius.xl)
                    .fill(
                        LinearGradient(
                            colors: [stageColor.opacity(0.25), AppColor.surface, stageColor.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 170)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.xl)
                            .stroke(stageColor.opacity(0.3), lineWidth: 1)
                    )

                VStack(spacing: AppSpacing.sm) {
                    Text("STAGE \(chapter.number)")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .tracking(2)
                        .foregroundColor(stageColor)
                    Text(chapter.title)
                        .font(AppTypography.title1)
                        .foregroundColor(AppColor.textPrimary)
                    HStack(spacing: AppSpacing.md) {
                        Label("\(chapter.estimatedMinutes) min", systemImage: "clock")
                        Label(chapter.isPremium ? "Premium" : "Free", systemImage: chapter.isPremium ? "crown.fill" : "checkmark.seal.fill")
                    }
                    .font(AppTypography.caption1)
                    .foregroundColor(AppColor.textSecondary)
                }
            }

            Text(chapter.summary)
                .font(AppTypography.body)
                .foregroundColor(AppColor.textSecondary)
        }
    }

    private var lessonRoadmap: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(title: "Lessons")

            let sampleLessons = DataMiddleware.sampleLessons(for: chapter.id)
            VStack(spacing: AppSpacing.xs) {
                ForEach(Array(sampleLessons.enumerated()), id: \.element.id) { index, lesson in
                    NavigationLink(value: NavigationRouter.Destination.lessonPlayer(lessonID: lesson.id, chapterID: chapter.id)) {
                        LessonRow(number: index + 1, title: lesson.title, isCompleted: index < 2, color: stageColor)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var practiceSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(title: "Practice")

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppSpacing.sm) {
                NavigationLink(value: NavigationRouter.Destination.flashcards(chapterID: chapter.id)) {
                    PracticeTypeCard(icon: "rectangle.on.rectangle", title: "Flashcards", count: 24, color: AppColor.diamond)
                }
                NavigationLink(value: NavigationRouter.Destination.wordBuilder(chapterID: chapter.id)) {
                    PracticeTypeCard(icon: "puzzlepiece.fill", title: "Word Builder", count: 12, color: AppColor.emerald)
                }
                NavigationLink(value: NavigationRouter.Destination.labeling(chapterID: chapter.id)) {
                    PracticeTypeCard(icon: "tag.fill", title: "Labeling", count: 8, color: AppColor.gold)
                }
                NavigationLink(value: NavigationRouter.Destination.caseStudy(chapterID: chapter.id)) {
                    PracticeTypeCard(icon: "doc.text.fill", title: "Case Study", count: 3, color: Color(hex: "FF6B9D"))
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var tutorSupportSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(title: "Tutor Support")

            NavigationLink(value: NavigationRouter.Destination.bookSession(sessionID: UUID())) {
                AppCard {
                    HStack {
                        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                            Text("Need help with this stage?")
                                .font(AppTypography.headline)
                                .foregroundColor(AppColor.textPrimary)
                            Text("Book a session with an expert tutor")
                                .font(AppTypography.subheadline)
                                .foregroundColor(AppColor.textSecondary)
                        }
                        Spacer()
                        Image(systemName: "person.fill.questionmark")
                            .font(.title2)
                            .foregroundColor(AppColor.gold)
                            .shadow(color: AppColor.gold.opacity(0.4), radius: 4)
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }

    private var glossaryPreview: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(title: "Key Terms", action: {}, actionLabel: "View All")

            VStack(spacing: AppSpacing.xs) {
                GlossaryRow(term: "oste/o", meaning: "bone")
                GlossaryRow(term: "arthr/o", meaning: "joint")
                GlossaryRow(term: "-itis", meaning: "inflammation")
            }
        }
    }
}

struct LessonRow: View {
    let number: Int
    let title: String
    let isCompleted: Bool
    let color: Color

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            ZStack {
                Circle()
                    .fill(isCompleted ? color.opacity(0.8) : AppColor.surfaceElevated)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Circle()
                            .stroke(isCompleted ? color : color.opacity(0.3), lineWidth: 1)
                    )
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.caption.bold())
                        .foregroundColor(.white)
                } else {
                    Text("\(number)")
                        .font(AppTypography.caption1)
                        .foregroundColor(color)
                }
            }
            .shadow(color: isCompleted ? color.opacity(0.4) : .clear, radius: 4)

            Text(title)
                .font(AppTypography.body)
                .foregroundColor(isCompleted ? AppColor.textPrimary : AppColor.textSecondary)
            Spacer()
            if !isCompleted {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(AppColor.textTertiary)
            }
        }
        .padding(.vertical, AppSpacing.xs)
    }
}

struct PracticeTypeCard: View {
    let icon: String
    let title: String
    let count: Int
    let color: Color

    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .shadow(color: color.opacity(0.5), radius: 4)
            Text(title)
                .font(AppTypography.subheadline)
                .foregroundColor(AppColor.textPrimary)
            Text("\(count) items")
                .font(AppTypography.caption2)
                .foregroundColor(AppColor.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.md)
        .background(AppColor.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.md)
                .stroke(color.opacity(0.15), lineWidth: 1)
        )
    }
}

struct GlossaryRow: View {
    let term: String
    let meaning: String

    var body: some View {
        HStack {
            Text(term)
                .font(AppTypography.termDisplay)
                .foregroundColor(AppColor.diamond)
            Spacer()
            Text(meaning)
                .font(AppTypography.body)
                .foregroundColor(AppColor.textSecondary)
        }
        .padding(.vertical, AppSpacing.xs)
    }
}

#Preview {
    NavigationStack {
        ChapterDetailView(
            chapter: Chapter(id: UUID(), number: 3, title: "Skeletal System", summary: "Bones, joints, and musculoskeletal conditions", estimatedMinutes: 75, isPremium: true, coverArtURL: nil, accentColorHex: "50C878", prerequisiteIDs: [], unlockRule: .premium),
            colorIndex: 2
        )
    }
}
