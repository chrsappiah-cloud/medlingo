import SwiftUI

struct HomeView: View {
    @Environment(DataMiddleware.self) private var data
    @Environment(NavigationRouter.self) private var router
    @State private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    welcomeSection
                    continueLearnCard
                    stageCarousel
                    upcomingSessionCard
                    reviewQueueSection
                    copyrightFooter
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.top, AppSpacing.md)
                .padding(.bottom, AppSpacing.xxl)
            }
            .background(AppColor.background)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: NavigationRouter.Destination.self) { destination in
                destinationView(for: destination)
            }
        }
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private func destinationView(for destination: NavigationRouter.Destination) -> some View {
        switch destination {
        case .stageDetail(let chapter, let colorIndex):
            ChapterDetailView(chapter: chapter, colorIndex: colorIndex)
        case .lessonPlayer(let lessonID, let chapterID):
            let lessons = DataMiddleware.sampleLessons(for: chapterID)
            if let lesson = lessons.first(where: { $0.id == lessonID }) ?? lessons.first {
                LessonPlayerView(lesson: lesson, stageColor: AppColor.gold)
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
        case .sessionRoom:
            Text("Joining session...")
        case .messages:
            MessagingView(recipientID: UUID(), recipientName: "Tutor")
        case .settings:
            Text("Settings")
        case .adminConsole:
            AdminConsoleView()
        case .tutorProfile:
            TutorDiscoveryView()
        case .exercise:
            QuizView(exercise: nil)
        case .generationStudio:
            GenerationStudioView()
        case .collectionGallery:
            CollectionGalleryView()
        case .artworkDetail:
            CollectionGalleryView()
        }
    }

    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Medlingo")
                .font(AppTypography.largeTitle)
                .foregroundStyle(
                    LinearGradient(
                        colors: [AppColor.gold, AppColor.diamond, AppColor.gold],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: AppColor.gold.opacity(0.3), radius: 4)

            HStack(spacing: AppSpacing.lg) {
                HStack(spacing: AppSpacing.xxs) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(AppColor.streakOrange)
                        .shadow(color: AppColor.streakOrange.opacity(0.6), radius: 4)
                    Text("\(viewModel.currentStreak) day streak")
                        .font(AppTypography.subheadline)
                        .foregroundColor(AppColor.textSecondary)
                }
                HStack(spacing: AppSpacing.xxs) {
                    Image(systemName: "star.fill")
                        .foregroundColor(AppColor.xpGold)
                        .shadow(color: AppColor.xpGold.opacity(0.6), radius: 4)
                    Text("\(viewModel.totalXP) XP")
                        .font(AppTypography.subheadline)
                        .foregroundColor(AppColor.textSecondary)
                }
            }
        }
    }

    private var continueLearnCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                HStack {
                    VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                        Text("Continue Learning")
                            .font(AppTypography.caption1)
                            .foregroundColor(AppColor.gold)
                        Text(viewModel.currentStageTitle)
                            .font(AppTypography.headline)
                            .foregroundColor(AppColor.textPrimary)
                        Text(viewModel.currentLessonTitle)
                            .font(AppTypography.subheadline)
                            .foregroundColor(AppColor.textSecondary)
                    }
                    Spacer()
                    ProgressRing(progress: viewModel.stageProgress, lineWidth: 6, size: 52, color: AppColor.emerald)
                }
                NavigationLink(value: NavigationRouter.Destination.stageDetail(chapter: viewModel.currentStage, colorIndex: 2)) {
                    Text("Resume")
                        .font(AppTypography.headline)
                        .foregroundColor(AppColor.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppColor.goldGradient)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                }
                .simultaneousGesture(TapGesture().onEnded {
                    AnalyticsService.shared.track(.screenViewed(name: "lesson_resume"))
                })
            }
        }
    }

    private var stageCarousel: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(title: "Stages") {}

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.sm) {
                    ForEach(Array(viewModel.chapters.enumerated()), id: \.element.id) { index, chapter in
                        NavigationLink(value: NavigationRouter.Destination.stageDetail(chapter: chapter, colorIndex: index)) {
                            StageBadge(stageNumber: chapter.number, title: chapter.title, colorIndex: index)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var upcomingSessionCard: some View {
        Group {
            if viewModel.hasUpcomingSession {
                AppCard {
                    HStack {
                        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                            Text("Upcoming Session")
                                .font(AppTypography.caption1)
                                .foregroundColor(AppColor.diamond)
                            Text("Cardiovascular Terminology")
                                .font(AppTypography.headline)
                                .foregroundColor(AppColor.textPrimary)
                            Text("Tomorrow at 3:00 PM")
                                .font(AppTypography.subheadline)
                                .foregroundColor(AppColor.textSecondary)
                        }
                        Spacer()
                        Image(systemName: "video.fill")
                            .font(.title2)
                            .foregroundColor(AppColor.diamond)
                            .shadow(color: AppColor.diamond.opacity(0.5), radius: 4)
                    }
                }
            }
        }
    }

    private var reviewQueueSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(title: "Review Queue", action: {
                AnalyticsService.shared.track(.screenViewed(name: "review_queue"))
            }, actionLabel: "Start Review")

            HStack(spacing: AppSpacing.sm) {
                StatTile(title: "Terms Due", value: "\(viewModel.termsDueForReview)", icon: "clock.arrow.circlepath", color: AppColor.diamond)
                StatTile(title: "Mastery", value: "\(Int(viewModel.overallMastery * 100))%", icon: "brain.head.profile", color: AppColor.emerald)
            }
        }
    }

    private var copyrightFooter: some View {
        Text(AppConstants.copyright)
            .font(AppTypography.caption2)
            .foregroundColor(AppColor.textTertiary)
            .frame(maxWidth: .infinity)
            .padding(.top, AppSpacing.lg)
    }
}

@MainActor
@Observable
final class HomeViewModel {
    var currentStreak: Int = 7
    var totalXP: Int = 1250
    var currentStageTitle: String = "Stage 3: Skeletal System"
    var currentLessonTitle: String = "Bone Structure & Function"
    var stageProgress: Double = 0.45
    var chapters: [Chapter] = []
    var hasUpcomingSession: Bool = true
    var termsDueForReview: Int = 12
    var overallMastery: Double = 0.72

    var currentStage: Chapter {
        chapters.first(where: { $0.number == 3 }) ?? chapters.first ?? Chapter(id: UUID(), number: 3, title: "Skeletal System", summary: "Bones, joints, and conditions", estimatedMinutes: 75, isPremium: false, coverArtURL: nil, accentColorHex: "50C878", prerequisiteIDs: [], unlockRule: .free)
    }

    init() {
        loadSampleStages()
    }

    private func loadSampleStages() {
        chapters = [
            Chapter(id: UUID(), number: 1, title: "Foundations", summary: "Word parts", estimatedMinutes: 45, isPremium: false, coverArtURL: nil, accentColorHex: "B9F2FF", prerequisiteIDs: [], unlockRule: .free),
            Chapter(id: UUID(), number: 2, title: "Body Org.", summary: "Orientation", estimatedMinutes: 50, isPremium: false, coverArtURL: nil, accentColorHex: "D4AF37", prerequisiteIDs: [], unlockRule: .sequential),
            Chapter(id: UUID(), number: 3, title: "Skeletal", summary: "Bones", estimatedMinutes: 75, isPremium: false, coverArtURL: nil, accentColorHex: "50C878", prerequisiteIDs: [], unlockRule: .free),
            Chapter(id: UUID(), number: 4, title: "Muscular", summary: "Muscles", estimatedMinutes: 60, isPremium: false, coverArtURL: nil, accentColorHex: "E6E6FA", prerequisiteIDs: [], unlockRule: .free),
            Chapter(id: UUID(), number: 5, title: "Nervous", summary: "Nerves", estimatedMinutes: 90, isPremium: false, coverArtURL: nil, accentColorHex: "FF6B9D", prerequisiteIDs: [], unlockRule: .free),
        ]
    }
}

#Preview {
    HomeView()
        .environment(DataMiddleware.shared)
        .environment(NavigationRouter())
}
