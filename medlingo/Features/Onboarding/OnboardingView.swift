import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    var onComplete: () -> Void

    private let pages: [(icon: String, title: String, subtitle: String)] = [
        ("stethoscope", "Master Medical Terminology", "Learn prefixes, roots, and suffixes through structured, stage-based lessons aligned to real textbook curricula."),
        ("puzzlepiece.extension.fill", "Interactive Practice", "Build terms, label anatomy, solve cases, and test yourself with flashcards, quizzes, and spaced review."),
        ("person.2.fill", "Expert Tutor Support", "Book live sessions with verified medical terminology tutors for personalized guidance and feedback."),
        ("chart.line.uptrend.xyaxis", "Track Your Mastery", "See your progress across stages, identify weak areas, and maintain your study streak."),
    ]

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    VStack(spacing: AppSpacing.xl) {
                        Spacer()
                        Image(systemName: page.icon)
                            .font(.system(size: 80))
                            .foregroundStyle(AppColor.goldGradient)
                            .shadow(color: AppColor.gold.opacity(0.4), radius: 12)
                            .padding(.bottom, AppSpacing.md)

                        VStack(spacing: AppSpacing.sm) {
                            Text(page.title)
                                .font(AppTypography.title1)
                                .multilineTextAlignment(.center)
                                .foregroundColor(AppColor.textPrimary)

                            Text(page.subtitle)
                                .font(AppTypography.body)
                                .multilineTextAlignment(.center)
                                .foregroundColor(AppColor.textSecondary)
                                .padding(.horizontal, AppSpacing.xl)
                        }
                        Spacer()
                        Spacer()
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            VStack(spacing: AppSpacing.md) {
                PrimaryButton(title: currentPage == pages.count - 1 ? "Get Started" : "Continue") {
                    if currentPage < pages.count - 1 {
                        withAnimation { currentPage += 1 }
                    } else {
                        onComplete()
                    }
                }

                if currentPage < pages.count - 1 {
                    GhostButton(title: "Skip") { onComplete() }
                }

                Text(AppConstants.copyright)
                    .font(AppTypography.caption2)
                    .foregroundColor(AppColor.textTertiary)
                    .padding(.top, AppSpacing.xs)
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.bottom, AppSpacing.xl)
        }
        .background(AppColor.background)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    OnboardingView {}
}
