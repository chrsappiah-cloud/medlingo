import SwiftUI

struct AccountView: View {
    @Environment(AppState.self) private var appState
    @State private var showSignOutAlert = false
    @State private var showDeleteAlert = false

    var body: some View {
        NavigationStack {
            List {
                profileSection
                preferencesSection
                supportSection
                dangerZone
                copyrightSection
            }
            .scrollContentBackground(.hidden)
            .background(AppColor.background)
            .navigationTitle("Account")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .alert("Sign Out", isPresented: $showSignOutAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Sign Out", role: .destructive) {
                    Task { try? await appState.authService.signOut() }
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
            .alert("Delete Account", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    Task { try? await appState.authService.deleteAccount() }
                }
            } message: {
                Text("This action is permanent and cannot be undone. All your data will be deleted.")
            }
        }
        .preferredColorScheme(.dark)
    }

    private var profileSection: some View {
        Section {
            HStack(spacing: AppSpacing.md) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AppColor.gold.opacity(0.4), AppColor.emerald.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                        .overlay(Circle().stroke(AppColor.gold.opacity(0.5), lineWidth: 1.5))
                    Text("C")
                        .font(AppTypography.title2)
                        .foregroundColor(AppColor.gold)
                }
                .shadow(color: AppColor.gold.opacity(0.3), radius: 6)

                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text("Christopher")
                        .font(AppTypography.headline)
                        .foregroundColor(AppColor.textPrimary)
                    Text("christopher@email.com")
                        .font(AppTypography.subheadline)
                        .foregroundColor(AppColor.textSecondary)
                }
            }
            .padding(.vertical, AppSpacing.xs)
            .listRowBackground(AppColor.surface)
        }
    }

    private var preferencesSection: some View {
        Section("Preferences") {
            NavigationLink {
                NotificationsSettingsView()
            } label: {
                Label("Notifications", systemImage: "bell.fill")
                    .foregroundColor(AppColor.textPrimary)
            }
            NavigationLink {
                StudyRemindersView()
            } label: {
                Label("Study Reminders", systemImage: "alarm.fill")
                    .foregroundColor(AppColor.textPrimary)
            }
            NavigationLink {
                AppearanceSettingsView()
            } label: {
                Label("Appearance", systemImage: "paintbrush.fill")
                    .foregroundColor(AppColor.textPrimary)
            }
        }
        .listRowBackground(AppColor.surface)
    }

    private var supportSection: some View {
        Section("Support") {
            NavigationLink {
                HelpCenterView()
            } label: {
                Label("Help Center", systemImage: "questionmark.circle.fill")
                    .foregroundColor(AppColor.textPrimary)
            }
            Link(destination: AppConstants.privacyURL) {
                Label("Privacy Policy", systemImage: "hand.raised.fill")
                    .foregroundColor(AppColor.textPrimary)
            }
            Link(destination: AppConstants.termsURL) {
                Label("Terms of Service", systemImage: "doc.text.fill")
                    .foregroundColor(AppColor.textPrimary)
            }
        }
        .listRowBackground(AppColor.surface)
    }

    private var dangerZone: some View {
        Section {
            Button {
                showSignOutAlert = true
            } label: {
                Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                    .foregroundColor(AppColor.error)
            }
            .accessibilityIdentifier("sign-out-button")
            Button {
                showDeleteAlert = true
            } label: {
                Label("Delete Account", systemImage: "trash.fill")
                    .foregroundColor(AppColor.error.opacity(0.7))
            }
        }
        .listRowBackground(AppColor.surface)
    }

    private var copyrightSection: some View {
        Section {
            VStack(spacing: AppSpacing.xs) {
                Text(AppConstants.appName)
                    .font(AppTypography.caption1)
                    .foregroundColor(AppColor.textTertiary)
                Text("Version \(AppConstants.version) (\(AppConstants.buildNumber))")
                    .font(AppTypography.caption2)
                    .foregroundColor(AppColor.textTertiary)
                Text(AppConstants.copyright)
                    .font(AppTypography.caption2)
                    .foregroundColor(AppColor.textTertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.sm)
            .listRowBackground(Color.clear)
        }
    }
}

// MARK: - Sub-screens

struct NotificationsSettingsView: View {
    @State private var lessonReminders = true
    @State private var sessionAlerts = true
    @State private var streakReminders = true
    @State private var tutorMessages = true

    var body: some View {
        List {
            Section("Learning") {
                Toggle("Lesson Reminders", isOn: $lessonReminders)
                Toggle("Streak Reminders", isOn: $streakReminders)
            }
            .listRowBackground(AppColor.surface)
            Section("Sessions") {
                Toggle("Session Alerts", isOn: $sessionAlerts)
                Toggle("Tutor Messages", isOn: $tutorMessages)
            }
            .listRowBackground(AppColor.surface)
        }
        .scrollContentBackground(.hidden)
        .background(AppColor.background)
        .navigationTitle("Notifications")
        .preferredColorScheme(.dark)
    }
}

struct StudyRemindersView: View {
    @State private var reminderEnabled = true
    @State private var reminderTime = Date()
    @State private var dailyGoal = 15

    var body: some View {
        List {
            Section("Daily Reminder") {
                Toggle("Enable Reminder", isOn: $reminderEnabled)
                if reminderEnabled {
                    DatePicker("Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                }
            }
            .listRowBackground(AppColor.surface)
            Section("Daily Goal") {
                Stepper("Exercises: \(dailyGoal)", value: $dailyGoal, in: 5...50, step: 5)
            }
            .listRowBackground(AppColor.surface)
        }
        .scrollContentBackground(.hidden)
        .background(AppColor.background)
        .navigationTitle("Study Reminders")
        .preferredColorScheme(.dark)
    }
}

struct AppearanceSettingsView: View {
    @State private var selectedTheme = 0

    var body: some View {
        List {
            Section("Theme") {
                Picker("Appearance", selection: $selectedTheme) {
                    Text("Dark").tag(0)
                    Text("Light").tag(1)
                    Text("System").tag(2)
                }
                .pickerStyle(.segmented)
            }
            .listRowBackground(AppColor.surface)
        }
        .scrollContentBackground(.hidden)
        .background(AppColor.background)
        .navigationTitle("Appearance")
        .preferredColorScheme(.dark)
    }
}

struct HelpCenterView: View {
    var body: some View {
        List {
            Section("FAQ") {
                FAQRow(question: "Are all stages available?", answer: "Yes. All stages, lessons, and practice modes are included at no cost.")
                FAQRow(question: "How do tutor sessions work?", answer: "Browse available tutors, book a session, and join via video call at the scheduled time.")
                FAQRow(question: "Can I study offline?", answer: "Yes! Previously loaded stages and flashcards are cached locally for offline access.")
            }
            .listRowBackground(AppColor.surface)
            Section("Contact Us") {
                Link(destination: URL(string: "mailto:\(AppConstants.supportEmail)")!) {
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Email Support")
                                .font(AppTypography.subheadline)
                                .foregroundColor(AppColor.textPrimary)
                            Text(AppConstants.supportEmail)
                                .font(AppTypography.caption1)
                                .foregroundColor(AppColor.textSecondary)
                        }
                    } icon: {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(AppColor.diamond)
                    }
                }
                Link(destination: AppConstants.websiteURL) {
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Website")
                                .font(AppTypography.subheadline)
                                .foregroundColor(AppColor.textPrimary)
                            Text("wcs-full.vercel.app")
                                .font(AppTypography.caption1)
                                .foregroundColor(AppColor.textSecondary)
                        }
                    } icon: {
                        Image(systemName: "globe")
                            .foregroundColor(AppColor.gold)
                    }
                }
            }
            .listRowBackground(AppColor.surface)
            Section {
                Text(AppConstants.copyright)
                    .font(AppTypography.caption2)
                    .foregroundColor(AppColor.textTertiary)
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppColor.background)
        .navigationTitle("Help Center")
        .preferredColorScheme(.dark)
    }
}

struct FAQRow: View {
    let question: String
    let answer: String
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Button {
                withAnimation { isExpanded.toggle() }
            } label: {
                HStack {
                    Text(question)
                        .font(AppTypography.subheadline)
                        .foregroundColor(AppColor.textPrimary)
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(AppColor.textTertiary)
                        .font(.caption)
                }
            }
            if isExpanded {
                Text(answer)
                    .font(AppTypography.caption1)
                    .foregroundColor(AppColor.textSecondary)
            }
        }
    }
}

#Preview {
    AccountView()
        .environment(AppState.shared)
}
