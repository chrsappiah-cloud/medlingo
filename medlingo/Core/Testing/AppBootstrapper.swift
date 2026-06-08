import Foundation

@MainActor
protocol AppBootstrapperProtocol {
    func bootstrap(
        authService: any AuthServiceProtocol,
        collectionStore: CollectionStore,
        analyticsService: AnalyticsService,
        configuration: AppLaunchConfiguration
    ) async
}

@MainActor
struct LiveAppBootstrapper: AppBootstrapperProtocol {
    func bootstrap(
        authService: any AuthServiceProtocol,
        collectionStore: CollectionStore,
        analyticsService: AnalyticsService,
        configuration: AppLaunchConfiguration
    ) async {
        RuntimeLogger.log(.lifecycle, "bootstrap start offline=\(configuration.isOfflineNetwork)")

        analyticsService.track(.appOpened)

        if configuration.isUITestMode {
            RuntimeLogger.log(.lifecycle, "bootstrap skipped — UI test mode")
            return
        }

        if configuration.isOfflineNetwork {
            RuntimeLogger.log(.network, "bootstrap skipped network sync — offline mock")
            return
        }

        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                do {
                    try await authService.refreshSession()
                    RuntimeLogger.log(.auth, "session refreshed")
                } catch {
                    RuntimeLogger.log(.auth, "session refresh skipped: \(error.localizedDescription)")
                }
            }
            group.addTask {
                await collectionStore.loadCollection()
                RuntimeLogger.log(.lifecycle, "collection loaded")
            }
        }

        RuntimeLogger.log(.lifecycle, "bootstrap complete")
    }
}
