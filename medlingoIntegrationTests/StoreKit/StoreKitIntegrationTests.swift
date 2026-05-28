import Testing
@testable import medlingo

@MainActor
struct StoreKitIntegrationTests {
    @Test func restorePurchases_mockRestoreEmpty_clearsEntitlements() async throws {
        let service = StoreKitService(
            launchConfiguration: AppLaunchConfiguration(arguments: ["-mockStoreKit", "restoreSuccess"])
        )
        try await service.restorePurchases()
        #expect(service.purchasedProductIDs.contains("com.medlingo.premium.yearly"))

        let emptyService = StoreKitService(
            launchConfiguration: AppLaunchConfiguration(arguments: ["-mockStoreKit", "restoreEmpty"])
        )
        try await emptyService.restorePurchases()
        #expect(emptyService.purchasedProductIDs.isEmpty)
    }
}
