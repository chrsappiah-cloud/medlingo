import Foundation
import SwiftUI
import StoreKit

@MainActor
@Observable
final class AppState {
    static let shared = AppState()

    let launchConfiguration = AppLaunchConfiguration.shared
    let permissionProvider: PermissionProviderProtocol
    private let bootstrapper: AppBootstrapperProtocol

    // Services
    let authService: AuthService
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
    var isUITesting: Bool { launchConfiguration.isUITestMode }
    var isPremium: Bool { !storeKitService.purchasedProductIDs.isEmpty }
    var currentUserID: UUID?

    var isCreatorRole: Bool {
        currentUserRole == .administrator || currentUserRole == .superAdmin
    }

    init(
        authService: AuthService? = nil,
        bootstrapper: AppBootstrapperProtocol? = nil,
        permissionProvider: PermissionProviderProtocol? = nil,
        sessionStore: SessionStoreProtocol? = nil
    ) {
        let configuration = AppLaunchConfiguration.shared
        self.bootstrapper = bootstrapper ?? LiveAppBootstrapper()
        self.permissionProvider = permissionProvider
            ?? FakePermissionProvider(scenario: configuration.permissionScenario)
        self.authService = authService ?? AuthService(sessionStore: sessionStore ?? UserDefaultsSessionStore())

        if configuration.isUITestMode {
            currentUserRole = configuration.seedsCreatorRole ? .administrator : .learner
            isOnboardingComplete = true
        } else if configuration.seedsCreatorRole {
            currentUserRole = .administrator
        }
        if configuration.seedsExpiredToken {
            self.authService.seedExpiredSessionForTesting()
        }
    }

    func bootstrap() async {
        await bootstrapper.bootstrap(
            authService: authService,
            storeKitService: storeKitService,
            collectionStore: collectionStore,
            analyticsService: analyticsService,
            configuration: launchConfiguration
        )
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
