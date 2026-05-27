import Foundation
@testable import medlingo

enum TestDataFactory {
    static func user(
        id: UUID = UUID(),
        email: String = "test@medlingo.com",
        role: AppUser.UserRole = .learner
    ) -> AppUser {
        AppUser(
            id: id,
            email: email,
            displayName: "Test User",
            role: role,
            status: .active,
            institutionID: nil,
            createdAt: Date(timeIntervalSince1970: 1_700_000_000),
            updatedAt: Date(timeIntervalSince1970: 1_700_000_000)
        )
    }

    static func authSession(
        user: AppUser? = nil,
        accessToken: String = "test-access-token",
        refreshToken: String = "test-refresh-token"
    ) -> AuthSession {
        AuthSession(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresIn: 3600,
            user: user ?? TestDataFactory.user()
        )
    }

    static func entitlement(expired: Bool = false) -> Entitlement {
        Entitlement(
            id: UUID(),
            userID: UUID(),
            productID: "com.medlingo.premium.monthly",
            status: .active,
            expiresAt: expired ? Date().addingTimeInterval(-86_400) : Date().addingTimeInterval(86_400 * 30),
            grantedAt: Date(),
            source: .applePurchase
        )
    }
}
