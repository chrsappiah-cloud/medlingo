import Foundation

struct Entitlement: Identifiable, Codable, Hashable {
    let id: UUID
    let userID: UUID
    let productID: String
    let status: EntitlementStatus
    let expiresAt: Date?
    let grantedAt: Date
    let source: EntitlementSource

    enum EntitlementStatus: String, Codable, Hashable {
        case active
        case expired
        case revoked
        case gracePeriod = "grace_period"
        case billingRetry = "billing_retry"
    }

    enum EntitlementSource: String, Codable, Hashable {
        case applePurchase = "apple_purchase"
        case adminGrant = "admin_grant"
        case institutional
        case promotional
    }

    var isValid: Bool {
        switch status {
        case .active, .gracePeriod:
            if let expiresAt {
                return expiresAt > Date()
            }
            return true
        default:
            return false
        }
    }
}
