import Testing
@testable import medlingo

@MainActor
struct AppStateTests {
    @Test func isPremium_whenNoPurchases_isFalse() {
        #expect(AppState.shared.isPremium == false)
    }

    @Test func isUITesting_whenLaunchArgSet_isTrue() {
        let config = AppLaunchConfiguration(arguments: ["-UITesting"])
        #expect(config.isUITestMode == true)
    }

    @Test func handlePurchase_whenProductMissing_throwsProductNotFound() async {
        await #expect(throws: StoreError.self) {
            _ = try await AppState.shared.handlePurchase(productID: "com.medlingo.premium.yearly")
        }
    }
}
