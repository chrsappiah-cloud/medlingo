import Foundation
import SwiftUI
import StoreKit

@MainActor
@Observable
final class AppState {
    static let shared = AppState()

    // Services
    let authService = AuthService()
    let storeKitService = StoreKitService()
    let analyticsService = AnalyticsService.shared
    let chapterService = ChapterService()
    let cloudKitSync = CloudKitSyncService()
    let syncCoordinator = SyncCoordinator.shared
    let pronunciationService = PronunciationService.shared

    // App-wide state
    var isOnboardingComplete = true
    var currentUserRole: AppUser.UserRole = .learner
    var isPremium: Bool { !storeKitService.purchasedProductIDs.isEmpty }
    var currentUserID: UUID?

    private init() {}

    func bootstrap() async {
        storeKitService.startListening()
        try? await storeKitService.syncEntitlements()
        try? await authService.refreshSession()
        analyticsService.track(.appOpened)
    }

    func handlePurchase(productID: String) async throws -> PurchaseResult {
        guard let product = storeKitService.availableProducts.first(where: { $0.id == productID }) else {
            throw StoreError.purchaseFailed
        }
        analyticsService.track(.purchaseInitiated(productID: productID))
        let result = try await storeKitService.purchase(product)
        switch result {
        case .success(let txID):
            analyticsService.track(.purchaseCompleted(productID: productID, revenue: product.price))
            _ = txID
        case .failed(let error):
            analyticsService.track(.purchaseFailed(productID: productID, reason: error.localizedDescription))
        default:
            break
        }
        return result
    }
}
