import Testing
@testable import medlingo

@MainActor
struct AppBootstrapperTests {
    @Test func bootstrap_whenUITestMode_skipsStoreKitAndAuth() async {
        let bootstrapper = LiveAppBootstrapper()
        let auth = AuthService(client: MockNetworkClient(), sessionStore: InMemorySessionStore())
        let storeKit = StoreKitService()
        let config = AppLaunchConfiguration(arguments: ["-UITesting"])

        await bootstrapper.bootstrap(
            authService: auth,
            storeKitService: storeKit,
            collectionStore: .shared,
            analyticsService: .shared,
            configuration: config
        )

        #expect(storeKit.purchasedProductIDs.isEmpty)
    }

    @Test func bootstrap_whenOffline_skipsNetworkWork() async {
        let bootstrapper = LiveAppBootstrapper()
        let auth = AuthService(client: MockNetworkClient(), sessionStore: InMemorySessionStore())
        let storeKit = StoreKitService()
        let config = AppLaunchConfiguration(arguments: ["-mockNetwork", "offline"])

        await bootstrapper.bootstrap(
            authService: auth,
            storeKitService: storeKit,
            collectionStore: .shared,
            analyticsService: .shared,
            configuration: config
        )

        #expect(auth.isAuthenticated == false)
    }
}
