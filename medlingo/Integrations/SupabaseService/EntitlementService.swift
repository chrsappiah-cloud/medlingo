import Foundation

@MainActor
final class EntitlementService: EntitlementServiceProtocol {
    private let client: NetworkClientProtocol
    private let functionsClient: NetworkClientProtocol

    init(client: NetworkClientProtocol? = nil, functionsClient: NetworkClientProtocol? = nil) {
        self.client = client ?? SupabaseManager.shared.networkClient
        self.functionsClient = functionsClient ?? SupabaseManager.shared.functionsClient
    }

    func fetchEntitlements(for userID: UUID) async throws -> [Entitlement] {
        try await client.request(Endpoint(path: "entitlements", queryItems: [
            URLQueryItem(name: "user_id", value: "eq.\(userID.uuidString)"),
            URLQueryItem(name: "order", value: "granted_at.desc")
        ]))
    }

    func verifyPurchase(transactionID: String, productID: String, userID: UUID, signedPayload: String) async throws -> Entitlement {
        let payload: [String: String] = [
            "transaction_id": transactionID,
            "product_id": productID,
            "user_id": userID.uuidString,
            "signed_payload": signedPayload
        ]
        let body = try JSONEncoder().encode(payload)
        return try await functionsClient.request(
            Endpoint(path: "purchase-verify", method: .post, body: body)
        )
    }

    func overrideEntitlement(userID: UUID, productID: String, status: Entitlement.EntitlementStatus) async throws {
        let payload: [String: String] = ["status": status.rawValue]
        let body = try JSONEncoder().encode(payload)
        try await client.request(Endpoint(
            path: "entitlements",
            method: .patch,
            body: body,
            queryItems: [
                URLQueryItem(name: "user_id", value: "eq.\(userID.uuidString)"),
                URLQueryItem(name: "product_id", value: "eq.\(productID)")
            ]
        ))
    }
}
