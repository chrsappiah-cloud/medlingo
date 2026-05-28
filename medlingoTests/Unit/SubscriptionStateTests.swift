import Testing
import Foundation
@testable import medlingo

struct SubscriptionStateTests {
    @Test func entitlement_whenExpired_isNotValid() {
        #expect(TestDataFactory.entitlement(expired: true).isValid == false)
    }

    @Test func entitlement_whenActive_isValid() {
        #expect(TestDataFactory.entitlement(expired: false).isValid == true)
    }

    @MainActor
    @Test func storeKit_loadProducts_whenProductsFailure_throws() async {
        let config = AppLaunchConfiguration(arguments: ["-mockStoreKit", "productsFailure"])
        let service = StoreKitService(launchConfiguration: config)

        await #expect(throws: StoreError.self) {
            _ = try await service.loadProducts()
        }
    }

    @MainActor
    @Test func storeKit_restore_whenRestoreSuccess_setsPurchasedIDs() async throws {
        let config = AppLaunchConfiguration(arguments: ["-mockStoreKit", "restoreSuccess"])
        let service = StoreKitService(launchConfiguration: config)

        try await service.restorePurchases()

        #expect(service.purchasedProductIDs.contains("com.medlingo.premium.yearly"))
    }
}
