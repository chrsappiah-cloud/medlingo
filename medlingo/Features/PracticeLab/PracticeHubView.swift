import SwiftUI

struct PracticeHubView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    dailyGoalSection
                    practiceModesGrid
                    weakAreasSection
                    recentAttemptsSection
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.top, AppSpacing.md)
                .padding(.bottom, AppSpacing.xxl)
            }
            .background(AppColor.background)
            .navigationTitle("Practice Lab")
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }

    private var dailyGoalSection: some View {
        AppCard {
            HStack {
                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text("Daily Goal")
                        .font(AppTypography.caption1)
                        .foregroundColor(AppColor.gold)
                    Text("8 / 15 exercises")
                        .font(AppTypography.headline)
                        .foregroundColor(AppColor.textPrimary)
                }
                Spacer()
                ProgressRing(progress: 8.0 / 15.0, lineWidth: 8, size: 56, color: AppColor.gold)
            }
        }
    }

    private var practiceModesGrid: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(title: "Practice Modes")

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppSpacing.sm) {
                NavigationLink(destination: FlashcardsView()) {
                    PracticeModeCard(icon: "rectangle.on.rectangle.angled", title: "Flashcards", subtitle: "Quick recall", color: AppColor.diamond)
                }
                NavigationLink(destination: WordBuilderView()) {
                    PracticeModeCard(icon: "puzzlepiece.extension.fill", title: "Word Builder", subtitle: "Build terms", color: AppColor.emerald)
                }
                NavigationLink(destination: LabelingView()) {
                    PracticeModeCard(icon: "figure.stand", title: "Labeling", subtitle: "Anatomy ID", color: AppColor.gold)
                }
                NavigationLink(destination: QuizView(exercise: nil)) {
                    PracticeModeCard(icon: "questionmark.circle.fill", title: "Quiz", subtitle: "Test knowledge", color: Color(hex: "FF6B9D"))
                }
                NavigationLink(destination: CaseStudyView()) {
                    PracticeModeCard(icon: "doc.text.magnifyingglass", title: "Case Studies", subtitle: "Apply learning", color: Color(hex: "FF4500"))
                }
                NavigationLink(destination: FlashcardsView()) {
                    PracticeModeCard(icon: "textformat.abc", title: "Abbreviations", subtitle: "Medical abbrev.", color: Color(hex: "7B68EE"))
                }
            }
            .buttonStyle(.plain)
        }
    }

    private var weakAreasSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(title: "Weak Areas", action: {}, actionLabel: "Practice All")

            VStack(spacing: AppSpacing.xs) {
                WeakAreaRow(term: "-ectomy", accuracy: 0.45, attempts: 8)
                WeakAreaRow(term: "nephro-", accuracy: 0.55, attempts: 6)
                WeakAreaRow(term: "-plasty", accuracy: 0.60, attempts: 5)
            }
        }
    }

    private var recentAttemptsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(title: "Recent Attempts")

            VStack(spacing: AppSpacing.xs) {
                AttemptRow(exercise: "Stage 3 Quiz", score: 0.85, date: "Today")
                AttemptRow(exercise: "Word Builder: Cardio", score: 0.70, date: "Yesterday")
                AttemptRow(exercise: "Flashcards: Stage 2", score: 0.92, date: "2 days ago")
            }
        }
    }
}

struct PracticeModeCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .shadow(color: color.opacity(0.5), radius: 4)
            Text(title)
                .font(AppTypography.headline)
                .foregroundColor(AppColor.textPrimary)
            Text(subtitle)
                .font(AppTypography.caption1)
                .foregroundColor(AppColor.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.md)
        .background(AppColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.md)
                .stroke(color.opacity(0.15), lineWidth: 1)
        )
    }
}

struct WeakAreaRow: View {
    let term: String
    let accuracy: Double
    let attempts: Int

    var body: some View {
        HStack {
            Text(term)
                .font(AppTypography.termDisplay)
                .foregroundColor(AppColor.error)
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(Int(accuracy * 100))% accuracy")
                    .font(AppTypography.caption1)
                    .foregroundColor(AppColor.textSecondary)
                Text("\(attempts) attempts")
                    .font(AppTypography.caption2)
                    .foregroundColor(AppColor.textTertiary)
            }
        }
        .padding(.vertical, AppSpacing.xs)
    }
}

struct AttemptRow: View {
    let exercise: String
    let score: Double
    let date: String

    var scoreColor: Color {
        if score >= 0.8 { return AppColor.emerald }
        if score >= 0.6 { return AppColor.gold }
        return AppColor.error
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(exercise)
                    .font(AppTypography.subheadline)
                    .foregroundColor(AppColor.textPrimary)
                Text(date)
                    .font(AppTypography.caption2)
                    .foregroundColor(AppColor.textTertiary)
            }
            Spacer()
            Text("\(Int(score * 100))%")
                .font(AppTypography.headline)
                .foregroundColor(scoreColor)
                .shadow(color: scoreColor.opacity(0.3), radius: 2)
        }
        .padding(.vertical, AppSpacing.xs)
    }
}

#Preview {
    PracticeHubView()
}
