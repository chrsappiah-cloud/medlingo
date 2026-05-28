import Testing
import Foundation
@testable import medlingo

@MainActor
struct EntitlementServiceTests {
    var mockClient: MockNetworkClient
    var sut: EntitlementService

    init() {
        mockClient = MockNetworkClient()
        sut = EntitlementService(client: mockClient, functionsClient: mockClient)
    }

    @Test func fetchEntitlements_usesCorrectPathAndQuery() async throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let userID = UUID()
        let expected = [Entitlement(id: UUID(), userID: userID, productID: "premium", status: .active, expiresAt: Date().addingTimeInterval(86400), grantedAt: Date(), source: .applePurchase)]
        mockClient.requestHandler = { _ in try encoder.encode(expected) }

        let entitlements = try await sut.fetchEntitlements(for: userID)

        #expect(entitlements.count == 1)
        #expect(mockClient.lastEndpoint?.path == "entitlements")
        #expect(mockClient.lastEndpoint?.queryItems?.contains(where: { $0.value == "eq.\(userID.uuidString)" }) == true)
    }

    @Test func fetchEntitlements_whenEmpty_returnsEmptyArray() async throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        mockClient.requestHandler = { _ in try encoder.encode([Entitlement]()) }

        let entitlements = try await sut.fetchEntitlements(for: UUID())

        #expect(entitlements.isEmpty)
    }

    @Test func verifyPurchase_usesPostMethod() async throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let payload = Entitlement(id: UUID(), userID: UUID(), productID: "test", status: .active, expiresAt: Date().addingTimeInterval(86400), grantedAt: Date(), source: .applePurchase)
        mockClient.requestHandler = { _ in try encoder.encode(payload) }

        _ = try await sut.verifyPurchase(transactionID: "txn123", productID: "com.test.product", userID: UUID(), signedPayload: "signed")

        #expect(mockClient.lastEndpoint?.method == .post)
        #expect(mockClient.lastEndpoint?.path == "purchase-verify")
    }

    @Test func overrideEntitlement_usesPatchMethod() async throws {
        mockClient.requestHandler = { _ in Data() }

        try await sut.overrideEntitlement(userID: UUID(), productID: "test", status: .active)

        #expect(mockClient.lastEndpoint?.method == .patch)
        #expect(mockClient.lastEndpoint?.path == "entitlements")
    }
}
