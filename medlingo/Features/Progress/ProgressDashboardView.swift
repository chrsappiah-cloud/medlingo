import SwiftUI

struct ProgressDashboardView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    overallStatsSection
                    streakSection
                    stageProgressSection
                    learningAnalyticsSection
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.top, AppSpacing.md)
                .padding(.bottom, AppSpacing.xxl)
            }
            .background(AppColor.background)
            .navigationTitle("Progress")
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }

    private var overallStatsSection: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: AppSpacing.sm) {
            StatTile(title: "XP Earned", value: "1,250", icon: "star.fill", color: AppColor.xpGold)
            StatTile(title: "Stages", value: "3/15", icon: "flag.fill", color: AppColor.diamond)
            StatTile(title: "Mastery", value: "72%", icon: "brain.head.profile", color: AppColor.emerald)
        }
    }

    private var streakSection: some View {
        AppCard {
            HStack {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    HStack(spacing: AppSpacing.xxs) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(AppColor.streakOrange)
                            .font(.title2)
                            .shadow(color: AppColor.streakOrange.opacity(0.6), radius: 6)
                        Text("7 Day Streak!")
                            .font(AppTypography.title2)
                            .foregroundColor(AppColor.textPrimary)
                    }
                    Text("Keep it going! Study today to maintain your streak.")
                        .font(AppTypography.subheadline)
                        .foregroundColor(AppColor.textSecondary)
                }
                Spacer()
                weekDotsView
            }
        }
    }

    private var weekDotsView: some View {
        HStack(spacing: 4) {
            ForEach(0..<7, id: \.self) { day in
                Circle()
                    .fill(day < 7 ? AppColor.streakOrange : AppColor.textTertiary.opacity(0.3))
                    .frame(width: 10, height: 10)
                    .shadow(color: day < 7 ? AppColor.streakOrange.opacity(0.5) : .clear, radius: 2)
            }
        }
    }

    private var stageProgressSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(title: "Stage Progress")

            VStack(spacing: AppSpacing.xs) {
                StageProgressRow(number: 1, title: "Word Parts & Foundations", progress: 1.0, color: AppColor.stageColors[0])
                StageProgressRow(number: 2, title: "Body Organization", progress: 0.85, color: AppColor.stageColors[1])
                StageProgressRow(number: 3, title: "Integumentary System", progress: 0.45, color: AppColor.stageColors[2])
                StageProgressRow(number: 4, title: "Skeletal System", progress: 0.12, color: AppColor.stageColors[3])
                StageProgressRow(number: 5, title: "Muscular System", progress: 0, color: AppColor.stageColors[4])
            }
        }
    }

    private var learningAnalyticsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(title: "Learning Analytics")

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppSpacing.sm) {
                AnalyticCard(title: "Term Building", accuracy: 0.78, icon: "puzzlepiece.fill", color: AppColor.emerald)
                AnalyticCard(title: "Abbreviations", accuracy: 0.65, icon: "textformat.abc", color: AppColor.gold)
                AnalyticCard(title: "Labeling", accuracy: 0.82, icon: "tag.fill", color: AppColor.diamond)
                AnalyticCard(title: "Case Studies", accuracy: 0.71, icon: "doc.text.fill", color: Color(hex: "FF6B9D"))
            }
        }
    }
}

struct StageProgressRow: View {
    let number: Int
    let title: String
    let progress: Double
    let color: Color

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            ZStack {
                Circle()
                    .fill(progress >= 1.0 ? color.opacity(0.3) : AppColor.surfaceElevated)
                    .frame(width: 28, height: 28)
                    .overlay(Circle().stroke(color.opacity(0.5), lineWidth: 1))
                if progress >= 1.0 {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(color)
                } else {
                    Text("\(number)")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(color)
                }
            }
            .shadow(color: progress >= 1.0 ? color.opacity(0.4) : .clear, radius: 3)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(AppTypography.subheadline)
                        .foregroundColor(AppColor.textPrimary)
                    Spacer()
                    Text("\(Int(progress * 100))%")
                        .font(AppTypography.caption1)
                        .foregroundColor(color)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(color.opacity(0.12))
                            .frame(height: 5)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(
                                LinearGradient(
                                    colors: [color, color.opacity(0.6)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * progress, height: 5)
                            .shadow(color: color.opacity(0.5), radius: 2)
                    }
                }
                .frame(height: 5)
            }
        }
    }
}

struct AnalyticCard: View {
    let title: String
    let accuracy: Double
    let icon: String
    var color: Color

    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .shadow(color: color.opacity(0.4), radius: 3)
                Spacer()
                Text("\(Int(accuracy * 100))%")
                    .font(AppTypography.headline)
                    .foregroundColor(color)
            }
            Text(title)
                .font(AppTypography.subheadline)
                .foregroundColor(AppColor.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(color.opacity(0.12))
                        .frame(height: 5)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(color)
                        .frame(width: geo.size.width * accuracy, height: 5)
                        .shadow(color: color.opacity(0.4), radius: 2)
                }
            }
            .frame(height: 5)
        }
        .padding(AppSpacing.md)
        .background(AppColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.md)
                .stroke(color.opacity(0.12), lineWidth: 1)
        )
    }
}

#Preview {
    ProgressDashboardView()
}
