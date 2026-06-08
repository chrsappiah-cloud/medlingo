import Testing
@testable import medlingo

@MainActor
struct AppBootstrapperTests {
    @Test func bootstrap_whenUITestMode_skipsBoot() async {
        let bootstrapper = LiveAppBootstrapper()
        let auth = AuthService(client: MockNetworkClient(), sessionStore: InMemorySessionStore())
        let config = AppLaunchConfiguration(arguments: ["-UITesting"])

        await bootstrapper.bootstrap(
            authService: auth,
            collectionStore: .shared,
            analyticsService: .shared,
            configuration: config
        )
    }

    @Test func bootstrap_whenOffline_skipsNetworkWork() async {
        let bootstrapper = LiveAppBootstrapper()
        let auth = AuthService(client: MockNetworkClient(), sessionStore: InMemorySessionStore())
        let config = AppLaunchConfiguration(arguments: ["-mockNetwork", "offline"])

        await bootstrapper.bootstrap(
            authService: auth,
            collectionStore: .shared,
            analyticsService: .shared,
            configuration: config
        )

        #expect(auth.isAuthenticated == false)
    }
}
