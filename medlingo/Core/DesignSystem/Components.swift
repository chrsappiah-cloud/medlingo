import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.xs) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                }
                Text(title)
                    .font(AppTypography.headline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.md)
            .background(AppColor.goldGradient)
            .foregroundColor(AppColor.primaryDark)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
            .shadow(color: AppColor.gold.opacity(0.4), radius: 8, x: 0, y: 4)
        }
        .disabled(isLoading)
    }
}

struct SecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTypography.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.md)
                .background(AppColor.surfaceElevated)
                .foregroundColor(AppColor.diamond)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.md)
                        .stroke(AppColor.diamond.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

struct GhostButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    init(title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.xs) {
                if let icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .font(AppTypography.subheadline)
            }
            .foregroundColor(AppColor.gold)
        }
    }
}

struct AppCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(AppSpacing.md)
            .background(AppColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.lg)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 6)
    }
}

struct GlassCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(AppSpacing.md)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.lg)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.2), .white.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
}

struct SectionHeader: View {
    let title: String
    var action: (() -> Void)? = nil
    var actionLabel: String = "See All"

    var body: some View {
        HStack {
            Text(title)
                .font(AppTypography.title3)
                .foregroundColor(AppColor.textPrimary)
            Spacer()
            if let action {
                Button(actionLabel, action: action)
                    .font(AppTypography.subheadline)
                    .foregroundColor(AppColor.gold)
            }
        }
    }
}

struct ProgressRing: View {
    let progress: Double
    let lineWidth: CGFloat
    let size: CGFloat
    var color: Color = AppColor.emerald

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.15), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        colors: [color, color.opacity(0.6), color],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(duration: 0.8), value: progress)
            Circle()
                .fill(color)
                .frame(width: lineWidth * 0.8, height: lineWidth * 0.8)
                .offset(y: -(size / 2))
                .rotationEffect(.degrees(360 * progress - 90))
                .opacity(progress > 0 ? 1 : 0)
                .shadow(color: color, radius: 3)
        }
        .frame(width: size, height: size)
    }
}

struct StageBadge: View {
    let stageNumber: Int
    let title: String
    let colorIndex: Int

    private var stageColor: Color {
        AppColor.stageColors[colorIndex % AppColor.stageColors.count]
    }

    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [stageColor.opacity(0.4), stageColor.opacity(0.1)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 28
                        )
                    )
                    .frame(width: 56, height: 56)
                    .overlay(
                        Circle()
                            .stroke(stageColor.opacity(0.6), lineWidth: 1.5)
                    )
                Text("\(stageNumber)")
                    .font(AppTypography.title2)
                    .foregroundColor(stageColor)
                    .shadow(color: stageColor.opacity(0.5), radius: 2)
            }
            Text(title)
                .font(AppTypography.caption1)
                .foregroundColor(AppColor.textSecondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(width: 80)
    }
}

struct StatTile: View {
    let title: String
    let value: String
    let icon: String
    var color: Color = AppColor.gold

    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .shadow(color: color.opacity(0.5), radius: 4)
            Text(value)
                .font(AppTypography.statValue)
                .foregroundColor(AppColor.textPrimary)
            Text(title)
                .font(AppTypography.caption1)
                .foregroundColor(AppColor.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.md)
        .background(AppColor.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.md)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

struct TutorAvatarCard: View {
    let name: String
    let specialty: String
    let rating: Double
    let pricePerHour: String

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppColor.gold.opacity(0.3), AppColor.emerald.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                    .overlay(
                        Circle().stroke(AppColor.gold.opacity(0.4), lineWidth: 1)
                    )
                Text(String(name.prefix(1)))
                    .font(AppTypography.title2)
                    .foregroundColor(AppColor.gold)
            }

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(name)
                    .font(AppTypography.headline)
                    .foregroundColor(AppColor.textPrimary)
                Text(specialty)
                    .font(AppTypography.subheadline)
                    .foregroundColor(AppColor.textSecondary)
                HStack(spacing: AppSpacing.xxs) {
                    Image(systemName: "star.fill")
                        .foregroundColor(AppColor.xpGold)
                        .font(.caption)
                    Text(String(format: "%.1f", rating))
                        .font(AppTypography.caption1)
                        .foregroundColor(AppColor.textSecondary)
                    Spacer()
                    Text(pricePerHour)
                        .font(AppTypography.caption1)
                        .foregroundColor(AppColor.gold)
                        .fontWeight(.semibold)
                }
            }
        }
        .padding(AppSpacing.md)
        .background(AppColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.md)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }
}
