import SwiftUI

struct AdminConsoleView: View {
    @State private var showStudio = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    creatorStudioBanner
                    metricsOverview
                    quickActions
                    recentActivitySection
                    pendingApprovalsSection
                    Text(AppConstants.copyright)
                        .font(AppTypography.caption2)
                        .foregroundColor(AppColor.textTertiary)
                        .frame(maxWidth: .infinity)
                        .padding(.top, AppSpacing.lg)
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.top, AppSpacing.md)
                .padding(.bottom, AppSpacing.xxl)
            }
            .background(AppColor.background)
            .navigationTitle("Admin Console")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .fullScreenCover(isPresented: $showStudio) {
                NavigationStack {
                    GenerationStudioView()
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                Button("Close") { showStudio = false }
                                    .foregroundColor(AppColor.diamond)
                            }
                        }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var creatorStudioBanner: some View {
        Button { showStudio = true } label: {
            HStack(spacing: AppSpacing.md) {
                ZStack {
                    Circle()
                        .fill(AppColor.diamond.opacity(0.12))
                        .frame(width: 52, height: 52)
                    Image(systemName: "wand.and.stars")
                        .font(.system(size: 24))
                        .foregroundStyle(AppColor.diamondPowerGradient)
                        .shadow(color: AppColor.diamond.opacity(0.5), radius: 6)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("AI Generation Studio")
                        .font(AppTypography.headline)
                        .foregroundColor(AppColor.textPrimary)
                    Text("Create art & video with open-source AI")
                        .font(AppTypography.caption1)
                        .foregroundColor(AppColor.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.subheadline)
                    .foregroundColor(AppColor.diamond)
            }
            .padding(AppSpacing.md)
            .background(
                LinearGradient(
                    colors: [AppColor.diamond.opacity(0.08), AppColor.surface],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.lg)
                    .stroke(AppColor.diamond.opacity(0.2), lineWidth: 1)
            )
        }
    }

    private var metricsOverview: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(title: "Overview")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppSpacing.sm) {
                AdminMetricCard(title: "Active Learners", value: "1,284", trend: "+12%", icon: "person.3.fill", color: AppColor.diamond)
                AdminMetricCard(title: "Lessons Completed", value: "12,450", trend: "+8%", icon: "book.fill", color: AppColor.success)
                AdminMetricCard(title: "Study Streaks", value: "856", trend: "+5%", icon: "flame.fill", color: AppColor.diamondDeep)
                AdminMetricCard(title: "Sessions This Week", value: "47", trend: "+15%", icon: "video.fill", color: AppColor.emerald)
            }
        }
    }

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(title: "Quick Actions")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: AppSpacing.sm) {
                AdminActionButton(icon: "person.badge.plus", title: "Users", color: .blue)
                AdminActionButton(icon: "checkmark.shield.fill", title: "Approvals", color: .green)
                AdminActionButton(icon: "book.fill", title: "Content", color: .purple)
                AdminActionButton(icon: "chart.bar.fill", title: "Analytics", color: .orange)
                AdminActionButton(icon: "flag.fill", title: "Reports", color: .red)
                AdminActionButton(icon: "gearshape.fill", title: "Settings", color: .gray)
            }
        }
    }

    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(title: "Recent Activity", action: {}, actionLabel: "View All")

            VStack(spacing: AppSpacing.xs) {
                AdminActivityRow(icon: "person.fill.checkmark", text: "New tutor verified: James Chen", time: "2m ago", color: .green)
                AdminActivityRow(icon: "book.fill", text: "Chapter 8 published", time: "15m ago", color: .blue)
                AdminActivityRow(icon: "star.fill", text: "New learner milestone: 100-day streak", time: "1h ago", color: .orange)
                AdminActivityRow(icon: "video.fill", text: "Tutor session completed: Cardiology", time: "3h ago", color: .green)
            }
        }
    }

    private var pendingApprovalsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(title: "Pending Approvals")

            VStack(spacing: AppSpacing.xs) {
                ApprovalRow(name: "Dr. Linda Park", type: "Tutor Application", submitted: "2 days ago")
                ApprovalRow(name: "Marcus Lee", type: "Tutor Application", submitted: "3 days ago")
            }
        }
    }
}

struct AdminMetricCard: View {
    let title: String
    let value: String
    let trend: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .shadow(color: color.opacity(0.5), radius: 4)
                Spacer()
                Text(trend)
                    .font(AppTypography.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(AppColor.success)
            }
            Text(value)
                .font(AppTypography.title2)
                .foregroundColor(AppColor.textPrimary)
            Text(title)
                .font(AppTypography.caption1)
                .foregroundColor(AppColor.textSecondary)
        }
        .padding(AppSpacing.md)
        .background(AppColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.md)
                .stroke(color.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: color.opacity(0.06), radius: 6, x: 0, y: 3)
    }
}

struct AdminActionButton: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            Text(title)
                .font(AppTypography.caption1)
                .foregroundColor(AppColor.textPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.md)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
    }
}

struct AdminActivityRow: View {
    let icon: String
    let text: String
    let time: String
    let color: Color

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            Text(text)
                .font(AppTypography.subheadline)
                .foregroundColor(AppColor.textPrimary)
            Spacer()
            Text(time)
                .font(AppTypography.caption2)
                .foregroundColor(AppColor.textTertiary)
        }
        .padding(.vertical, AppSpacing.xs)
    }
}

struct ApprovalRow: View {
    let name: String
    let type: String
    let submitted: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(AppTypography.subheadline)
                    .foregroundColor(AppColor.textPrimary)
                Text("\(type) • \(submitted)")
                    .font(AppTypography.caption2)
                    .foregroundColor(AppColor.textTertiary)
            }
            Spacer()
            HStack(spacing: AppSpacing.xs) {
                Button {
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppColor.success)
                }
                Button {
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppColor.error)
                }
            }
        }
        .padding(.vertical, AppSpacing.xs)
    }
}

#Preview {
    AdminConsoleView()
}
