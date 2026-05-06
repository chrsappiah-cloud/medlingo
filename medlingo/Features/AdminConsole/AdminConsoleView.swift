import SwiftUI

struct AdminConsoleView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
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
        }
        .preferredColorScheme(.dark)
    }

    private var metricsOverview: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(title: "Overview")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppSpacing.sm) {
                AdminMetricCard(title: "Active Learners", value: "1,284", trend: "+12%", icon: "person.3.fill", color: AppColor.primary)
                AdminMetricCard(title: "Revenue (MTD)", value: "$8,450", trend: "+8%", icon: "dollarsign.circle.fill", color: AppColor.success)
                AdminMetricCard(title: "Active Subscriptions", value: "856", trend: "+5%", icon: "creditcard.fill", color: AppColor.info)
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
                AdminActionButton(icon: "creditcard.fill", title: "Payments", color: .orange)
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
                AdminActivityRow(icon: "creditcard.fill", text: "Refund processed: $9.99", time: "15m ago", color: .orange)
                AdminActivityRow(icon: "exclamationmark.triangle.fill", text: "Payment failed: user #4521", time: "1h ago", color: .red)
                AdminActivityRow(icon: "book.fill", text: "Chapter 8 published", time: "3h ago", color: .blue)
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
                Spacer()
                Text(trend)
                    .font(AppTypography.caption2)
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
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
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
