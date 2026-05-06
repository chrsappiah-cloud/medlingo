import SwiftUI

struct TutorDiscoveryView: View {
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    upcomingSessionBanner
                    tutorListSection
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.top, AppSpacing.md)
                .padding(.bottom, AppSpacing.xxl)
            }
            .background(AppColor.background)
            .navigationTitle("Sessions")
            .searchable(text: $searchText, prompt: "Search tutors or topics")
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }

    private var upcomingSessionBanner: some View {
        AppCard {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                HStack {
                    Image(systemName: "video.fill")
                        .foregroundColor(AppColor.diamond)
                        .shadow(color: AppColor.diamond.opacity(0.5), radius: 4)
                    Text("Next Session")
                        .font(AppTypography.caption1)
                        .foregroundColor(AppColor.diamond)
                    Spacer()
                    Text("In 2 hours")
                        .font(AppTypography.caption1)
                        .foregroundColor(AppColor.streakOrange)
                        .fontWeight(.medium)
                }

                Text("Cardiovascular Terminology Review")
                    .font(AppTypography.headline)
                    .foregroundColor(AppColor.textPrimary)

                HStack {
                    Circle()
                        .fill(
                            LinearGradient(colors: [AppColor.gold.opacity(0.3), AppColor.emerald.opacity(0.2)], startPoint: .top, endPoint: .bottom)
                        )
                        .frame(width: 28, height: 28)
                        .overlay(Text("D").font(.caption.bold()).foregroundColor(AppColor.gold))
                    Text("Dr. Sarah Mitchell")
                        .font(AppTypography.subheadline)
                        .foregroundColor(AppColor.textSecondary)
                    Spacer()
                    PrimaryButton(title: "Join") {}
                        .frame(width: 80)
                }
            }
        }
    }

    private var tutorListSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(title: "Available Tutors", action: {}, actionLabel: "Filter")

            VStack(spacing: AppSpacing.sm) {
                TutorAvatarCard(
                    name: "Dr. Sarah Mitchell",
                    specialty: "Cardiovascular & Respiratory",
                    rating: 4.9,
                    pricePerHour: "$45/hr"
                )
                TutorAvatarCard(
                    name: "James Chen",
                    specialty: "Nervous System & Special Senses",
                    rating: 4.8,
                    pricePerHour: "$38/hr"
                )
                TutorAvatarCard(
                    name: "Dr. Amara Okafor",
                    specialty: "Musculoskeletal & Integumentary",
                    rating: 4.7,
                    pricePerHour: "$42/hr"
                )
                TutorAvatarCard(
                    name: "Emily Rodriguez",
                    specialty: "Endocrine & Reproductive",
                    rating: 4.6,
                    pricePerHour: "$35/hr"
                )
            }
        }
    }
}

#Preview {
    TutorDiscoveryView()
}
