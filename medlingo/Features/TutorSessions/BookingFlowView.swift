import SwiftUI

struct BookingFlowView: View {
    let session: TutorSession
    @Environment(\.dismiss) private var dismiss
    @Environment(DataMiddleware.self) private var middleware
    @State private var isBooking = false
    @State private var bookingConfirmed = false
    @State private var isJoiningSession = false
    @State private var showSessionRoom = false
    @State private var roomURL: URL?
    @State private var roomToken: String?
    @State private var error: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.lg) {
                if bookingConfirmed {
                    confirmationView
                } else {
                    bookingForm
                }
            }
            .padding(AppSpacing.lg)
            .background(AppColor.background)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppColor.textTertiary)
                    }
                }
            }
            .fullScreenCover(isPresented: $showSessionRoom) {
                if let url = roomURL, let token = roomToken {
                    SessionRoomView(session: session, roomURL: url, token: token)
                }
            }
        }
    }

    private var bookingForm: some View {
        VStack(spacing: AppSpacing.lg) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 48))
                .foregroundColor(AppColor.gold)
                .shadow(color: AppColor.gold.opacity(0.4), radius: 8)

            VStack(spacing: AppSpacing.sm) {
                Text("Book Session")
                    .font(AppTypography.title1)
                    .foregroundColor(AppColor.textPrimary)
                Text(session.title)
                    .font(AppTypography.headline)
                    .foregroundColor(AppColor.textSecondary)
                    .multilineTextAlignment(.center)
            }

            AppCard {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    DetailRow(icon: "clock", label: "Duration", value: "\(session.durationMinutes) min")
                    DetailRow(icon: "calendar", label: "Date", value: session.startsAt.formatted(date: .abbreviated, time: .shortened))
                    DetailRow(icon: "person.2", label: "Seats Left", value: "\(session.seatsAvailable - session.seatsBooked)")
                    DetailRow(icon: "dollarsign.circle", label: "Price", value: "$\(String(format: "%.2f", Double(session.priceCents) / 100.0))")
                }
            }

            if let desc = session.description, !desc.isEmpty {
                AppCard {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text("About This Session")
                            .font(AppTypography.subheadline)
                            .foregroundColor(AppColor.textSecondary)
                        Text(desc)
                            .font(AppTypography.body)
                            .foregroundColor(AppColor.textPrimary)
                    }
                }
            }

            if let error {
                Text(error)
                    .font(AppTypography.caption1)
                    .foregroundColor(AppColor.error)
            }

            Spacer()

            PrimaryButton(title: "Confirm Booking", action: {
                Task { await bookSession() }
            }, isLoading: isBooking)

            SecondaryButton(title: "Cancel") { dismiss() }
        }
    }

    private var confirmationView: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 72))
                .foregroundColor(AppColor.emerald)
                .shadow(color: AppColor.emerald.opacity(0.5), radius: 12)

            Text("Booking Confirmed!")
                .font(AppTypography.title1)
                .foregroundColor(AppColor.textPrimary)

            Text("You'll receive a reminder before the session starts.")
                .font(AppTypography.body)
                .foregroundColor(AppColor.textSecondary)
                .multilineTextAlignment(.center)

            AppCard {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    HStack {
                        Image(systemName: "video.fill")
                            .foregroundColor(AppColor.diamond)
                        Text(session.title)
                            .font(AppTypography.headline)
                            .foregroundColor(AppColor.textPrimary)
                    }
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(AppColor.gold)
                        Text(session.startsAt.formatted(date: .abbreviated, time: .shortened))
                            .font(AppTypography.subheadline)
                            .foregroundColor(AppColor.textSecondary)
                    }
                }
            }

            Spacer()

            if isSessionJoinable {
                PrimaryButton(title: isJoiningSession ? "Connecting..." : "Join Now", action: {
                    Task { await joinNow() }
                }, isLoading: isJoiningSession)
            }

            SecondaryButton(title: "Done") { dismiss() }
        }
    }

    private var isSessionJoinable: Bool {
        let timeUntilStart = session.startsAt.timeIntervalSinceNow
        return timeUntilStart < 900
    }

    private func bookSession() async {
        isBooking = true
        error = nil

        let booking = await middleware.bookSession(sessionID: session.id)
        isBooking = false

        if booking != nil {
            withAnimation { bookingConfirmed = true }
        } else {
            error = "Failed to book session. Please try again."
        }
    }

    private func joinNow() async {
        isJoiningSession = true
        defer { isJoiningSession = false }

        if SupabaseManager.shared.isConfigured {
            if let result = await middleware.createSessionRoom(sessionID: session.id) {
                roomURL = result.url
                roomToken = result.token
                showSessionRoom = true
            } else {
                error = "Could not connect to session. Please try again."
            }
        } else {
            roomURL = URL(string: "\(Config.dailyRoomBaseURL)/medlingo-session-\(session.id.uuidString.prefix(8))")!
            roomToken = "demo-\(UUID().uuidString.prefix(8))"
            showSessionRoom = true
        }
    }
}

struct DetailRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(AppColor.gold)
                .frame(width: 24)
            Text(label)
                .font(AppTypography.subheadline)
                .foregroundColor(AppColor.textSecondary)
            Spacer()
            Text(value)
                .font(AppTypography.subheadline)
                .foregroundColor(AppColor.textPrimary)
        }
    }
}
