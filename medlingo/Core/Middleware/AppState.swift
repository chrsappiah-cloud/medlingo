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
    let collectionStore = CollectionStore.shared
    let inVideoAIService = InVideoAIService.shared

    // App-wide state
    var isOnboardingComplete = true
    var currentUserRole: AppUser.UserRole = .learner
    var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("-UITesting")
    }
    var isPremium: Bool { !storeKitService.purchasedProductIDs.isEmpty }
    var currentUserID: UUID?

    var isCreatorRole: Bool {
        currentUserRole == .administrator || currentUserRole == .superAdmin
    }

    private init() {
        if ProcessInfo.processInfo.arguments.contains("-UITesting") {
            currentUserRole = .learner
        }
    }

    func bootstrap() async {
        analyticsService.track(.appOpened)

        if isUITesting { return }

        storeKitService.startListening()

        await withTaskGroup(of: Void.self) { group in
            group.addTask { try? await self.storeKitService.syncEntitlements() }
            group.addTask { try? await self.authService.refreshSession() }
            group.addTask { await self.collectionStore.loadCollection() }
        }
    }

    func handlePurchase(productID: String) async throws -> PurchaseResult {
        guard let product = storeKitService.availableProducts.first(where: { $0.id == productID }) else {
            throw StoreError.productNotFound(productID: productID)
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
