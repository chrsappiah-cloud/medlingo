import SwiftUI

struct AccountView: View {
    @Environment(AppState.self) private var appState
    @State private var showSignOutAlert = false
    @State private var showDeleteAlert = false

    var body: some View {
        NavigationStack {
            List {
                profileSection
                subscriptionSection
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
                    HStack(spacing: AppSpacing.xxs) {
                        Image(systemName: "crown.fill")
                            .font(.caption2)
                            .foregroundColor(AppColor.gold)
                        Text("Premium")
                            .font(AppTypography.caption1)
                            .foregroundColor(AppColor.gold)
                    }
                }
            }
            .padding(.vertical, AppSpacing.xs)
            .listRowBackground(AppColor.surface)
        }
    }

    private var subscriptionSection: some View {
        Section("Subscription") {
            NavigationLink {
                SubscriptionView()
            } label: {
                HStack {
                    Label("Premium Plan", systemImage: "crown.fill")
                        .foregroundColor(AppColor.textPrimary)
                    Spacer()
                    Text("Active")
                        .font(AppTypography.caption1)
                        .foregroundColor(AppColor.emerald)
                }
            }
            NavigationLink {
                PurchaseHistoryView()
            } label: {
                Label("Purchase History", systemImage: "clock.arrow.circlepath")
                    .foregroundColor(AppColor.textPrimary)
            }
            Button {
                Task { try? await appState.storeKitService.restorePurchases() }
            } label: {
                Label("Restore Purchases", systemImage: "arrow.clockwise")
                    .foregroundColor(AppColor.diamond)
            }
        }
        .listRowBackground(AppColor.surface)
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

struct PurchaseHistoryView: View {
    var body: some View {
        List {
            ForEach(0..<3, id: \.self) { i in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(["Premium Monthly", "Session Pack (5)", "Premium Monthly"][i])
                            .font(AppTypography.subheadline)
                            .foregroundColor(AppColor.textPrimary)
                        Text(["May 6, 2026", "Apr 20, 2026", "Apr 6, 2026"][i])
                            .font(AppTypography.caption2)
                            .foregroundColor(AppColor.textTertiary)
                    }
                    Spacer()
                    Text(["$9.99", "$24.99", "$9.99"][i])
                        .font(AppTypography.subheadline)
                        .foregroundColor(AppColor.gold)
                }
            }
            .listRowBackground(AppColor.surface)
        }
        .scrollContentBackground(.hidden)
        .background(AppColor.background)
        .navigationTitle("Purchase History")
        .preferredColorScheme(.dark)
    }
}

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
                FAQRow(question: "How do I unlock premium stages?", answer: "Subscribe to Premium or purchase individual stage packs from the subscription page.")
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

struct SubscriptionView: View {
    @Environment(AppState.self) private var appState
    @State private var isLoadingProducts = false

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                currentPlanCard
                availablePlansSection
                copyrightFooter
            }
            .padding(AppSpacing.md)
        }
        .background(AppColor.background)
        .navigationTitle("Subscription")
        .preferredColorScheme(.dark)
        .task {
            isLoadingProducts = true
            _ = try? await appState.storeKitService.loadProducts()
            isLoadingProducts = false
        }
    }

    private var currentPlanCard: some View {
        AppCard {
            VStack(spacing: AppSpacing.sm) {
                Image(systemName: "crown.fill")
                    .font(.largeTitle)
                    .foregroundColor(AppColor.gold)
                    .shadow(color: AppColor.gold.opacity(0.6), radius: 8)
                Text("Premium Monthly")
                    .font(AppTypography.title2)
                    .foregroundColor(AppColor.textPrimary)
                Text("Renews June 6, 2026")
                    .font(AppTypography.subheadline)
                    .foregroundColor(AppColor.textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var availablePlansSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Available Plans")
                .font(AppTypography.title3)
                .foregroundColor(AppColor.textPrimary)

            PlanCard(
                name: "Monthly",
                price: "$9.99/mo",
                features: ["Full stage library", "All practice modes", "Progress analytics", "Tutor messaging"],
                isCurrentPlan: true,
                onUpgrade: {}
            )
            PlanCard(
                name: "Yearly",
                price: "$79.99/yr",
                features: ["Everything in Monthly", "Save 33%", "5 free tutor sessions", "Priority support"],
                isCurrentPlan: false,
                onUpgrade: {
                    Task { _ = try? await appState.handlePurchase(productID: "com.medlingo.premium.yearly") }
                }
            )
        }
    }

    private var copyrightFooter: some View {
        Text(AppConstants.copyright)
            .font(AppTypography.caption2)
            .foregroundColor(AppColor.textTertiary)
            .padding(.top, AppSpacing.lg)
    }
}

struct PlanCard: View {
    let name: String
    let price: String
    let features: [String]
    let isCurrentPlan: Bool
    let onUpgrade: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Text(name)
                    .font(AppTypography.headline)
                    .foregroundColor(AppColor.textPrimary)
                Spacer()
                Text(price)
                    .font(AppTypography.title3)
                    .foregroundStyle(AppColor.goldGradient)
            }
            ForEach(features, id: \.self) { feature in
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppColor.emerald)
                        .font(.caption)
                    Text(feature)
                        .font(AppTypography.subheadline)
                        .foregroundColor(AppColor.textSecondary)
                }
            }
            if isCurrentPlan {
                Text("Current Plan")
                    .font(AppTypography.caption1)
                    .foregroundColor(AppColor.gold)
                    .padding(.horizontal, AppSpacing.sm)
                    .padding(.vertical, AppSpacing.xxs)
                    .background(AppColor.gold.opacity(0.15))
                    .clipShape(Capsule())
            } else {
                PrimaryButton(title: "Upgrade", action: onUpgrade)
            }
        }
        .padding(AppSpacing.md)
        .background(AppColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .stroke(isCurrentPlan ? AppColor.gold.opacity(0.4) : Color.white.opacity(0.05), lineWidth: 1)
        )
    }
}

#Preview {
    AccountView()
        .environment(AppState.shared)
}
