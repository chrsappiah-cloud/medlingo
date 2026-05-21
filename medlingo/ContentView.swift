import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: AppTab = .learn
    private var isCreator: Bool {
        let role = AppState.shared.currentUserRole
        return role == .administrator || role == .superAdmin
    }

    enum AppTab: String, CaseIterable {
        case learn = "Learn"
        case practice = "Practice"
        case studio = "Studio"
        case collection = "Collection"
        case sessions = "Sessions"
        case progress = "Progress"
        case account = "Account"

        var icon: String {
            switch self {
            case .learn: return "book.fill"
            case .practice: return "brain.head.profile"
            case .studio: return "wand.and.stars"
            case .collection: return "photo.on.rectangle.angled"
            case .sessions: return "video.fill"
            case .progress: return "chart.bar.fill"
            case .account: return "person.fill"
            }
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label(AppTab.learn.rawValue, systemImage: AppTab.learn.icon)
                }
                .tag(AppTab.learn)

            PracticeHubView()
                .tabItem {
                    Label(AppTab.practice.rawValue, systemImage: AppTab.practice.icon)
                }
                .tag(AppTab.practice)

            if isCreator {
                GenerationStudioView()
                    .tabItem {
                        Label(AppTab.studio.rawValue, systemImage: AppTab.studio.icon)
                    }
                    .tag(AppTab.studio)
            }

            CollectionGalleryView()
                .tabItem {
                    Label(AppTab.collection.rawValue, systemImage: AppTab.collection.icon)
                }
                .tag(AppTab.collection)

            TutorDiscoveryView()
                .tabItem {
                    Label(AppTab.sessions.rawValue, systemImage: AppTab.sessions.icon)
                }
                .tag(AppTab.sessions)

            ProgressDashboardView()
                .tabItem {
                    Label(AppTab.progress.rawValue, systemImage: AppTab.progress.icon)
                }
                .tag(AppTab.progress)

            AccountView()
                .tabItem {
                    Label(AppTab.account.rawValue, systemImage: AppTab.account.icon)
                }
                .tag(AppTab.account)
        }
        .tint(AppColor.diamond)
        .onAppear { configureTabBarAppearance() }
        .preferredColorScheme(.dark)
    }

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(AppColor.surface)
        appearance.shadowColor = UIColor(AppColor.diamond.opacity(0.15))

        let normalAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(AppColor.tabInactive),
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]
        let selectedAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(AppColor.diamond),
            .font: UIFont.systemFont(ofSize: 10, weight: .bold)
        ]

        appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttrs
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttrs
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(AppColor.tabInactive)
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(AppColor.diamond)

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    MainTabView()
        .environment(AppState.shared)
        .environment(DataMiddleware.shared)
        .environment(NavigationRouter())
}
