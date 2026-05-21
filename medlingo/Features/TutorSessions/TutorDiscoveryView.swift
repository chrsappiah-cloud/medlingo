import SwiftUI

struct TutorDiscoveryView: View {
    @Environment(DataMiddleware.self) private var middleware
    @State private var searchText = ""
    @State private var showBooking = false
    @State private var selectedSession: TutorSession?
    @State private var activeRoomSession: TutorSession?
    @State private var roomURL: URL?
    @State private var roomToken: String?
    @State private var isJoining = false
    @State private var joinError: String?
    @State private var showAITutor = false
    @State private var aiTutorTopic: String = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    aiTutorBanner
                    upcomingSessionBanner
                    availableSessionsSection
                    bookedSessionsSection
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
            .fullScreenCover(item: $activeRoomSession) { session in
                if let url = roomURL, let token = roomToken {
                    SessionRoomView(session: session, roomURL: url, token: token)
                }
            }
            .fullScreenCover(isPresented: $showAITutor) {
                AITutorSessionView(topic: aiTutorTopic, chapterContext: "")
            }
            .alert("Join Error", isPresented: .init(get: { joinError != nil }, set: { if !$0 { joinError = nil } })) {
                Button("OK") { joinError = nil }
            } message: {
                Text(joinError ?? "")
            }
        }
        .preferredColorScheme(.dark)
        .task { await middleware.loadSessions() }
    }

    private var aiTutorBanner: some View {
        AppCard {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundColor(AppColor.diamond)
                        .shadow(color: AppColor.diamond.opacity(0.6), radius: 4)
                    Text("AI Tutor")
                        .font(AppTypography.caption1)
                        .foregroundColor(AppColor.diamond)
                    Spacer()
                    Text("Instant")
                        .font(AppTypography.caption2)
                        .foregroundColor(AppColor.emerald)
                        .padding(.horizontal, AppSpacing.xs)
                        .padding(.vertical, 2)
                        .background(AppColor.emerald.opacity(0.15))
                        .clipShape(Capsule())
                }

                Text("AI Avatar Sessions")
                    .font(AppTypography.headline)
                    .foregroundColor(AppColor.textPrimary)

                Text("Get a personalized video lesson from an AI tutor on any medical terminology topic — available 24/7.")
                    .font(AppTypography.caption1)
                    .foregroundColor(AppColor.textSecondary)
                    .lineSpacing(2)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppSpacing.xs) {
                        aiTopicChip("Cardiovascular Terms")
                        aiTopicChip("Nervous System")
                        aiTopicChip("Musculoskeletal")
                        aiTopicChip("Pharmacology Prefixes")
                        aiTopicChip("Surgical Suffixes")
                    }
                }

                PrimaryButton(title: "Start AI Session") {
                    aiTutorTopic = "Medical Terminology Overview"
                    showAITutor = true
                }
            }
        }
    }

    private func aiTopicChip(_ topic: String) -> some View {
        Button {
            aiTutorTopic = topic
            showAITutor = true
        } label: {
            Text(topic)
                .font(AppTypography.caption2)
                .foregroundColor(AppColor.diamond)
                .padding(.horizontal, AppSpacing.sm)
                .padding(.vertical, AppSpacing.xxs)
                .background(AppColor.diamond.opacity(0.1))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(AppColor.diamond.opacity(0.3), lineWidth: 0.5))
        }
    }

    private var availableSessionsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(title: "Upcoming Sessions")

            let sessions = filteredSessions
            if sessions.isEmpty {
                emptyState(icon: "calendar.badge.clock", text: "No upcoming sessions available")
            } else {
                ForEach(sessions) { session in
                    Button {
                        selectedSession = session
                    } label: {
                        SessionCard(session: session, actionLabel: "Book")
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var bookedSessionsSection: some View {
        Group {
            if !middleware.bookings.isEmpty {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    SectionHeader(title: "My Bookings")

                    ForEach(middleware.bookings) { booking in
                        let matchingSession = middleware.sessions.first(where: { $0.id == booking.sessionID })
                        if let session = matchingSession {
                            AppCard {
                                HStack {
                                    VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                                        Text(session.title)
                                            .font(AppTypography.headline)
                                            .foregroundColor(AppColor.textPrimary)
                                        Text(session.startsAt.formatted(date: .abbreviated, time: .shortened))
                                            .font(AppTypography.caption1)
                                            .foregroundColor(AppColor.textSecondary)
                                        HStack(spacing: AppSpacing.xxs) {
                                            Circle()
                                                .fill(AppColor.emerald)
                                                .frame(width: 6, height: 6)
                                            Text("Confirmed")
                                                .font(AppTypography.caption2)
                                                .foregroundColor(AppColor.emerald)
                                        }
                                    }
                                    Spacer()
                                    PrimaryButton(title: isJoining ? "..." : "Join") {
                                        Task { await joinSession(session) }
                                    }
                                    .frame(width: 80)
                                    .disabled(isJoining)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private var upcomingSessionBanner: some View {
        let nextSession = middleware.sessions.first ?? TutorSession(
            id: UUID(), tutorID: UUID(), title: "Cardiovascular Terminology Review",
            description: "Deep dive into cardio terms", startsAt: Date().addingTimeInterval(7200),
            durationMinutes: 45, priceCents: 4500, seatsAvailable: 10, seatsBooked: 3,
            chapterIDs: [], status: .scheduled
        )

        return AppCard {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                HStack {
                    Image(systemName: "video.fill")
                        .foregroundColor(AppColor.diamond)
                        .shadow(color: AppColor.diamond.opacity(0.5), radius: 4)
                    Text("Next Session")
                        .font(AppTypography.caption1)
                        .foregroundColor(AppColor.diamond)
                    Spacer()
                    Text(timeUntil(nextSession.startsAt))
                        .font(AppTypography.caption1)
                        .foregroundColor(AppColor.streakOrange)
                        .fontWeight(.medium)
                }

                Text(nextSession.title)
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
                    PrimaryButton(title: isJoining ? "Joining..." : "Join") {
                        Task { await joinSession(nextSession) }
                    }
                    .frame(width: 100)
                    .disabled(isJoining)
                }
            }
        }
    }

    private var tutorListSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(title: "Available Tutors", action: {}, actionLabel: "Filter")

            VStack(spacing: AppSpacing.sm) {
                tutorCard(name: "Dr. Sarah Mitchell", specialty: "Cardiovascular & Respiratory", rating: 4.9, price: "$45/hr")
                tutorCard(name: "James Chen", specialty: "Nervous System & Special Senses", rating: 4.8, price: "$38/hr")
                tutorCard(name: "Dr. Amara Okafor", specialty: "Musculoskeletal & Integumentary", rating: 4.7, price: "$42/hr")
                tutorCard(name: "Emily Rodriguez", specialty: "Endocrine & Reproductive", rating: 4.6, price: "$35/hr")
            }
        }
    }

    private func tutorCard(name: String, specialty: String, rating: Double, price: String) -> some View {
        Button {
            let session = TutorSession(
                id: UUID(), tutorID: UUID(), title: "\(name) - Private Session",
                description: specialty, startsAt: Date().addingTimeInterval(86400),
                durationMinutes: 60, priceCents: Int(Double(price.replacingOccurrences(of: "$", with: "").replacingOccurrences(of: "/hr", with: ""))! * 100),
                seatsAvailable: 1, seatsBooked: 0, chapterIDs: [], status: .scheduled
            )
            selectedSession = session
        } label: {
            TutorAvatarCard(name: name, specialty: specialty, rating: rating, pricePerHour: price)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Actions

    private func joinSession(_ session: TutorSession) async {
        isJoining = true
        defer { isJoining = false }

        if SupabaseManager.shared.isConfigured {
            if let result = await middleware.createSessionRoom(sessionID: session.id) {
                roomURL = result.url
                roomToken = result.token
                activeRoomSession = session
            } else {
                joinError = "Could not connect to session room. Please try again."
            }
        } else {
            let demoURL = URL(string: "\(Config.dailyRoomBaseURL)/medlingo-demo-\(session.id.uuidString.prefix(8))")!
            roomURL = demoURL
            roomToken = "demo-token-\(UUID().uuidString.prefix(8))"
            activeRoomSession = session
        }
    }

    // MARK: - Helpers

    private var filteredSessions: [TutorSession] {
        let sessions = middleware.sessions
        guard !searchText.isEmpty else { return sessions }
        return sessions.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            ($0.description ?? "").localizedCaseInsensitiveContains(searchText)
        }
    }

    private func timeUntil(_ date: Date) -> String {
        let interval = date.timeIntervalSinceNow
        if interval <= 0 { return "Now" }
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        if hours > 0 { return "In \(hours)h \(minutes)m" }
        return "In \(minutes)m"
    }

    private func emptyState(icon: String, text: String) -> some View {
        VStack(spacing: AppSpacing.sm) {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundColor(AppColor.textTertiary)
            Text(text)
                .font(AppTypography.body)
                .foregroundColor(AppColor.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.xl)
    }
}

struct SessionCard: View {
    let session: TutorSession
    let actionLabel: String

    var body: some View {
        AppCard {
            HStack {
                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text(session.title)
                        .font(AppTypography.headline)
                        .foregroundColor(AppColor.textPrimary)
                    Text(session.startsAt.formatted(date: .abbreviated, time: .shortened))
                        .font(AppTypography.caption1)
                        .foregroundColor(AppColor.textSecondary)
                    HStack(spacing: AppSpacing.xs) {
                        Label("\(session.durationMinutes) min", systemImage: "clock")
                            .font(AppTypography.caption2)
                            .foregroundColor(AppColor.textTertiary)
                        Text("•")
                            .foregroundColor(AppColor.textTertiary)
                        Text("\(session.seatsAvailable - session.seatsBooked) seats left")
                            .font(AppTypography.caption2)
                            .foregroundColor(AppColor.emerald)
                    }
                }
                Spacer()
                VStack(spacing: AppSpacing.xxs) {
                    Text("$\(String(format: "%.0f", Double(session.priceCents) / 100.0))")
                        .font(AppTypography.headline)
                        .foregroundColor(AppColor.gold)
                    Text(actionLabel)
                        .font(AppTypography.caption1)
                        .foregroundColor(AppColor.diamond)
                }
            }
        }
    }
}

#Preview {
    TutorDiscoveryView()
        .environment(DataMiddleware.shared)
}
