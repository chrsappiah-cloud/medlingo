import Foundation
import StoreKit

protocol PurchaseServiceProtocol {
    func loadProducts() async throws -> [Product]
    func purchase(_ product: Product) async throws -> PurchaseResult
    func syncEntitlements() async throws
    func restorePurchases() async throws
}

enum PurchaseResult {
    case success(transactionID: String)
    case pending
    case cancelled
    case failed(Error)
}

@MainActor
@Observable
final class StoreKitService: PurchaseServiceProtocol {
    private(set) var availableProducts: [Product] = []
    private(set) var purchasedProductIDs: Set<String> = []
    private(set) var isLoading = false

    var launchConfiguration: AppLaunchConfiguration = .shared
    private var transactionListener: Task<Void, Error>?

    init(launchConfiguration: AppLaunchConfiguration = .shared) {
        self.launchConfiguration = launchConfiguration
    }

    static let productIdentifiers: Set<String> = [
        "com.medlingo.premium.monthly",
        "com.medlingo.premium.yearly",
        "com.medlingo.sessions.5pack",
        "com.medlingo.sessions.10pack",
        "com.medlingo.chapter.unlock"
    ]

    func startListening() {
        transactionListener = Task {
            for await result in Transaction.updates {
                do {
                    let transaction = try Self.checkVerified(result)
                    await updatePurchasedProducts()
                    await transaction.finish()
                } catch {
                    // Transaction verification failed
                }
            }
        }
    }

    func stopListening() {
        transactionListener?.cancel()
        transactionListener = nil
    }

    func loadProducts() async throws -> [Product] {
        isLoading = true
        defer { isLoading = false }

        if let scenario = launchConfiguration.storeKitScenario {
            RuntimeLogger.log(.purchase, "loadProducts mock scenario=\(scenario.rawValue)")
            switch scenario {
            case .productsFailure, .offline:
                throw StoreError.purchaseFailed
            case .productsSuccess, .purchaseCancelled, .purchaseSuccess, .purchasePending, .restoreSuccess, .restoreEmpty:
                availableProducts = []
                return []
            }
        }

        let products = try await Product.products(for: Self.productIdentifiers)
        availableProducts = products.sorted { $0.price < $1.price }
        RuntimeLogger.log(.purchase, "loadProducts count=\(products.count)")
        return availableProducts
    }

    func purchase(_ product: Product) async throws -> PurchaseResult {
        isLoading = true
        defer { isLoading = false }

        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try Self.checkVerified(verification)
            await updatePurchasedProducts()
            await transaction.finish()
            // Forward signed transaction to backend for server-side reconciliation
            await verifyOnServer(transaction: transaction)
            return .success(transactionID: String(transaction.id))

        case .pending:
            return .pending

        case .userCancelled:
            return .cancelled

        @unknown default:
            return .cancelled
        }
    }

    func syncEntitlements() async throws {
        await updatePurchasedProducts()
    }

    func restorePurchases() async throws {
        if let scenario = launchConfiguration.storeKitScenario {
            RuntimeLogger.log(.purchase, "restorePurchases mock scenario=\(scenario.rawValue)")
            switch scenario {
            case .restoreEmpty:
                purchasedProductIDs = []
                return
            case .restoreSuccess, .purchaseSuccess:
                purchasedProductIDs = ["com.medlingo.premium.yearly"]
                return
            case .productsFailure, .offline:
                throw StoreError.purchaseFailed
            default:
                return
            }
        }
        try await AppStore.sync()
        await updatePurchasedProducts()
        RuntimeLogger.log(.purchase, "restorePurchases complete count=\(purchasedProductIDs.count)")
    }

    private func updatePurchasedProducts() async {
        var purchased: Set<String> = []
        for await result in Transaction.currentEntitlements {
            if let transaction = try? Self.checkVerified(result) {
                purchased.insert(transaction.productID)
            }
        }
        purchasedProductIDs = purchased
    }

    nonisolated private static func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }

    private func verifyOnServer(transaction: Transaction) async {
        let signedData = String(data: transaction.jsonRepresentation, encoding: .utf8) ?? ""
        guard !signedData.isEmpty else { return }

        guard let payload = try? JSONEncoder().encode(ReceiptVerificationPayload(
            transactionId: String(transaction.id),
            originalTransactionId: String(transaction.originalID),
            productId: transaction.productID,
            signedPayload: signedData
        )) else { return }

        guard SupabaseManager.shared.isConfigured else { return }

        do {
            let client = SupabaseManager.shared.functionsClient
            try await client.request(Endpoint(
                path: "verify-receipt",
                method: .post,
                body: payload
            ))
        } catch {
            // Server verification is non-blocking — purchase still succeeds locally
        }
    }
}

private struct ReceiptVerificationPayload: Encodable {
    let transactionId: String
    let originalTransactionId: String
    let productId: String
    let signedPayload: String
}

enum StoreError: Error, LocalizedError {
    case verificationFailed
    case purchaseFailed
    case serverVerificationFailed
    case productNotFound(productID: String)

    var errorDescription: String? {
        switch self {
        case .verificationFailed: return "Transaction verification failed"
        case .purchaseFailed: return "Purchase could not be completed"
        case .serverVerificationFailed: return "Server verification failed"
        case .productNotFound(let productID): return "Subscription product \"\(productID)\" is not available. Please ensure in-app purchases are configured in App Store Connect."
        }
    }
}
