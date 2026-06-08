import Testing
@testable import medlingo

@MainActor
struct AppBootstrapIntegrationTests {
    @Test func launchConfiguration_offlineAndUITestFlags() {
        let offline = AppLaunchConfiguration(arguments: ["-mockNetwork", "offline"])
        #expect(offline.isOfflineNetwork == true)

        let ui = AppLaunchConfiguration(arguments: ["-UITesting", "-seedExpiredToken"])
        #expect(ui.isUITestMode == true)
        #expect(ui.seedsExpiredToken == true)
    }

    @Test func bootstrapper_liveType_completesWithoutCrash() async {
        let bootstrapper = LiveAppBootstrapper()
        let auth = AuthService(client: MockNetworkClient(), sessionStore: InMemorySessionStore())

        await bootstrapper.bootstrap(
            authService: auth,
            collectionStore: .shared,
            analyticsService: .shared,
            configuration: AppLaunchConfiguration(arguments: ["-UITesting"])
        )
    }
}
