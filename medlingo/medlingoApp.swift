import SwiftUI
import SwiftData

@main
struct medlingoApp: App {
    @State private var appState = AppState.shared
    @State private var dataMiddleware = DataMiddleware.shared
    @State private var router = NavigationRouter()

    // MARK: - Lifecycle orchestrator (iOS Lifecycle Debugging Kit)
    // Initialised after the shared model container so both share one SwiftData store.

    @Environment(\.scenePhase) private var scenePhase

    // MARK: - Shared model container (single source of truth)

    let sharedModelContainer: ModelContainer = {
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

    // Lifecycle orchestrator shares the same model container — no duplicate stores.
    let lifecycleOrchestrator: AppLifecycleOrchestrator

    init() {
        lifecycleOrchestrator = AppLifecycleOrchestrator(
            persistence: AppPersistenceCoordinator(modelContainer: sharedModelContainer),
            sync: AppSyncCoordinator(middleware: .shared),
            backgroundTasks: AppBackgroundTaskCoordinator()
        )
    }

    // MARK: - Scene

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(appState)
                .environment(dataMiddleware)
                .environment(router)
                .task {
                    RuntimeLogger.log(.lifecycle, "app launch")
                    await appState.bootstrap()
                    // Mirror initial auth state into the orchestrator snapshot
                    lifecycleOrchestrator.updateAuth(appState.authService.isAuthenticated)
                    lifecycleOrchestrator.handle(.launched)
                }
                .onChange(of: scenePhase) { _, newPhase in
                    switch newPhase {
                    case .active:
                        lifecycleOrchestrator.updateAuth(appState.authService.isAuthenticated)
                        lifecycleOrchestrator.handle(.becameActive)
                    case .inactive:
                        lifecycleOrchestrator.handle(.willResignActive)
                    case .background:
                        lifecycleOrchestrator.handle(.enteredBackground)
                    @unknown default:
                        break
                    }
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
