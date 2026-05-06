import SwiftUI

struct TutorDiscoveryView: View {
    @State private var searchText = ""
    @State private var showBooking = false
    @State private var selectedSession: TutorSession?

    private let sampleSession = TutorSession(
        id: UUID(), tutorID: UUID(), title: "Cardiovascular Terminology Review",
        description: "Deep dive into cardio terms", startsAt: Date().addingTimeInterval(7200),
        durationMinutes: 45, priceCents: 4500, seatsAvailable: 10, seatsBooked: 3,
        chapterIDs: [], status: .scheduled
    )

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    upcomingSessionBanner
                    availableSessionsSection
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
            .sheet(item: $selectedSession) { session in
                BookingFlowView(session: session)
            }
        }
        .preferredColorScheme(.dark)
    }

    private var availableSessionsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(title: "Upcoming Sessions")

            let sessions = DataMiddleware.sampleSessions()
            ForEach(sessions) { session in
                Button {
                    selectedSession = session
                } label: {
                    AppCard {
                        HStack {
                            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                                Text(session.title)
                                    .font(AppTypography.headline)
                                    .foregroundColor(AppColor.textPrimary)
                                Text(session.startsAt.formatted(date: .abbreviated, time: .shortened))
                                    .font(AppTypography.caption1)
                                    .foregroundColor(AppColor.textSecondary)
                                Text("\(session.seatsAvailable - session.seatsBooked) seats left")
                                    .font(AppTypography.caption2)
                                    .foregroundColor(AppColor.emerald)
                            }
                            Spacer()
                            Text("$\(String(format: "%.0f", Double(session.priceCents) / 100.0))")
                                .font(AppTypography.headline)
                                .foregroundColor(AppColor.gold)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
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
