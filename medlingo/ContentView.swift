import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: AppTab = .learn

    enum AppTab: String, CaseIterable {
        case learn = "Learn"
        case practice = "Practice"
        case sessions = "Sessions"
        case progress = "Progress"
        case account = "Account"

        var icon: String {
            switch self {
            case .learn: return "book.fill"
            case .practice: return "brain.head.profile"
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
        .tint(AppColor.gold)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    MainTabView()
        .environment(AppState.shared)
        .environment(DataMiddleware.shared)
        .environment(NavigationRouter())
}
