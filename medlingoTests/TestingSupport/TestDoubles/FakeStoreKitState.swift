import Foundation
@testable import medlingo

/// Documents expected StoreKit mock scenarios for ARC Shield StoreKit Review Guard.
enum FakeStoreKitState {
    case productsLoaded
    case productsFailed
    case purchaseCancelled
    case purchaseSucceeded
    case purchasePending
    case restoreSucceeded
    case restoreEmpty
    case entitlementExpired
    case offline

    var launchScenario: StoreKitTestScenario {
        switch self {
        case .productsLoaded: return .productsSuccess
        case .productsFailed: return .productsFailure
        case .purchaseCancelled: return .purchaseCancelled
        case .purchaseSucceeded: return .purchaseSuccess
        case .purchasePending: return .purchasePending
        case .restoreSucceeded: return .restoreSuccess
        case .restoreEmpty: return .restoreEmpty
        case .entitlementExpired: return .restoreEmpty
        case .offline: return .offline
        }
    }
}
