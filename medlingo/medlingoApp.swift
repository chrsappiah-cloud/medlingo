import SwiftUI
import SwiftData

@main
struct medlingoApp: App {
    @State private var appState = AppState.shared
    @State private var dataMiddleware = DataMiddleware.shared
    @State private var router = NavigationRouter()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            CachedChapter.self,
            CachedProgress.self,
            PendingSyncAction.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            Group {
                if AppLaunchConfiguration.shared.showsSubscriptionForReview {
                    NavigationStack {
                        SubscriptionView()
                    }
                } else {
                    MainTabView()
                }
            }
            .environment(appState)
            .environment(dataMiddleware)
            .environment(router)
            .task {
                RuntimeLogger.log(.lifecycle, "app launch")
                await appState.bootstrap()
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
