import Foundation
@testable import medlingo

final class EntitlementServiceMock: EntitlementServiceProtocol {
    var fetchEntitlementsResult: Result<[Entitlement], Error> = .success([])
    var verifyPurchaseResult: Result<Entitlement, Error> = .success(
        Entitlement(id: UUID(), userID: UUID(), productID: "test", status: .active, expiresAt: Date().addingTimeInterval(86400 * 30), grantedAt: Date(), source: .applePurchase)
    )

    private(set) var fetchEntitlementsCallCount = 0
    private(set) var lastFetchUserID: UUID?
    private(set) var verifyPurchaseCallCount = 0
    private(set) var overrideEntitlementCallCount = 0

    func fetchEntitlements(for userID: UUID) async throws -> [Entitlement] {
        fetchEntitlementsCallCount += 1
        lastFetchUserID = userID
        return try fetchEntitlementsResult.get()
    }

    func verifyPurchase(transactionID: String, productID: String, userID: UUID, signedPayload: String) async throws -> Entitlement {
        verifyPurchaseCallCount += 1
        return try verifyPurchaseResult.get()
    }

    func overrideEntitlement(userID: UUID, productID: String, status: Entitlement.EntitlementStatus) async throws {
        overrideEntitlementCallCount += 1
    }
}
