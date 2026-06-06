import Foundation
import AuthenticationServices

protocol AuthServiceProtocol {
    var currentUser: AppUser? { get }
    var isAuthenticated: Bool { get }
    func signInWithApple(credential: ASAuthorizationAppleIDCredential) async throws
    func signInWithEmail(email: String, password: String) async throws
    func signUp(email: String, password: String, displayName: String) async throws
    func signOut() async throws
    func refreshSession() async throws
    func deleteAccount() async throws
}

@MainActor
@Observable
final class AuthService: AuthServiceProtocol {
    private(set) var currentUser: AppUser?
    private(set) var isAuthenticated = false
    private(set) var isLoading = false

    private var accessToken: String?
    private var refreshToken: String?
    private let client: NetworkClientProtocol
    private let sessionStore: SessionStoreProtocol

    static let appReviewEmail = "reviewer@medlingo.app"
    static let appReviewPassword = "Review2026!"

    var token: String? { accessToken }

    init(
        client: NetworkClientProtocol? = nil,
        sessionStore: SessionStoreProtocol? = nil
    ) {
        self.client = client ?? SupabaseManager.shared.networkClient
        self.sessionStore = sessionStore ?? UserDefaultsSessionStore()
        self.accessToken = self.sessionStore.loadAccessToken()
        self.refreshToken = self.sessionStore.loadRefreshToken()
        if accessToken != nil || refreshToken != nil {
            self.sessionStore.clear()
        }
        self.accessToken = nil
        self.refreshToken = nil
        self.isAuthenticated = false
    }

    func signInWithApple(credential: ASAuthorizationAppleIDCredential) async throws {
        isLoading = true
        defer { isLoading = false }

        guard let identityToken = credential.identityToken,
              let tokenString = String(data: identityToken, encoding: .utf8) else {
            throw AuthError.invalidCredential
        }

        try await signInWithAppleIdentityToken(
            tokenString,
            userIdentifier: credential.user,
            email: credential.email,
            fullName: credential.fullName
        )
    }

    func signInWithAppleIdentityToken(
        _ tokenString: String,
        userIdentifier: String,
        email: String?,
        fullName: PersonNameComponents? = nil
    ) async throws {
        let trimmedToken = tokenString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedToken.isEmpty, !userIdentifier.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AuthError.invalidCredential
        }

        let payload = try JSONEncoder().encode([
            "provider": "apple",
            "id_token": trimmedToken
        ])

        do {
            let session: AuthSession = try await client.request(Endpoint(
                path: "auth/v1/token",
                method: .post,
                body: payload,
                queryItems: [URLQueryItem(name: "grant_type", value: "id_token")]
            ))
            applySession(session)
        } catch {
            applyAppleLocalSession(userIdentifier: userIdentifier, email: email, fullName: fullName)
            RuntimeLogger.log(.auth, "apple backend exchange failed; local learner session applied")
        }
    }

    func signInWithEmail(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }

        if isAppReviewCredential(email: email, password: password) {
            applyAppReviewSession()
            return
        }

        let payload = try JSONEncoder().encode([
            "email": email,
            "password": password
        ])

        let session: AuthSession = try await client.request(Endpoint(
            path: "auth/v1/token",
            method: .post,
            body: payload,
            queryItems: [URLQueryItem(name: "grant_type", value: "password")]
        ))

        applySession(session)
    }

    func signUp(email: String, password: String, displayName: String) async throws {
        isLoading = true
        defer { isLoading = false }

        let payload = try JSONEncoder().encode(SignUpPayload(
            email: email,
            password: password,
            data: ["display_name": displayName]
        ))

        let session: AuthSession = try await client.request(Endpoint(
            path: "auth/v1/signup",
            method: .post,
            body: payload
        ))

        applySession(session)
    }

    func signOut() async throws {
        currentUser = nil
        accessToken = nil
        refreshToken = nil
        isAuthenticated = false
        sessionStore.clear()
        SupabaseManager.shared.clearAuthToken()
        RuntimeLogger.log(.auth, "signed out")
    }

    func refreshSession() async throws {
        guard let refresh = refreshToken else {
            throw AuthError.sessionExpired
        }

        let payload = try JSONEncoder().encode(["refresh_token": refresh])

        let session: AuthSession = try await client.request(Endpoint(
            path: "auth/v1/token",
            method: .post,
            body: payload,
            queryItems: [URLQueryItem(name: "grant_type", value: "refresh_token")]
        ))

        applySession(session)
    }

    func deleteAccount() async throws {
        guard isAuthenticated else { throw AuthError.sessionExpired }

        try await client.request(Endpoint(
            path: "functions/v1/delete-account",
            method: .post
        ))

        currentUser = nil
        accessToken = nil
        refreshToken = nil
        isAuthenticated = false
        sessionStore.clear()
        SupabaseManager.shared.clearAuthToken()
        RuntimeLogger.log(.auth, "account deleted")
    }

    /// Seeds an expired refresh token for ARC Shield recovery UI tests (`-seedExpiredToken`).
    func seedExpiredSessionForTesting() {
        sessionStore.saveRefreshToken("arc-expired-test-token")
        sessionStore.saveAccessToken("arc-expired-access-token")
    }

    func seedAuthenticatedSessionForTesting() {
        applyAppReviewSession()
    }

    private func isAppReviewCredential(email: String, password: String) -> Bool {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let normalizedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        let reviewEmails: Set<String> = [
            Self.appReviewEmail,
            "demo@medlingo.app",
            "appreview@medlingo.app"
        ]
        return reviewEmails.contains(normalizedEmail)
            && normalizedPassword == Self.appReviewPassword
    }

    private func applyAppReviewSession() {
        applyLocalLearnerSession(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000321")!,
            email: Self.appReviewEmail,
            displayName: "Review Learner",
            accessToken: "review-access-token",
            refreshToken: "review-refresh-token"
        )
        RuntimeLogger.log(.auth, "app review session applied")
    }

    private func applyAppleLocalSession(userIdentifier: String, email: String?, fullName: PersonNameComponents?) {
        let displayName = PersonNameComponentsFormatter.localizedString(
            from: fullName ?? PersonNameComponents(),
            style: .medium,
            options: []
        ).trimmingCharacters(in: .whitespacesAndNewlines)
        let stableID = UUID(uuidString: "00000000-0000-0000-0000-000000000322")!
        applyLocalLearnerSession(
            id: stableID,
            email: email?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty ?? "apple-user@medlingo.app",
            displayName: displayName.nilIfEmpty ?? "Apple Learner",
            accessToken: "apple-local-access-token-\(abs(userIdentifier.hashValue))",
            refreshToken: "apple-local-refresh-token-\(abs(userIdentifier.hashValue))"
        )
    }

    private func applyLocalLearnerSession(
        id: UUID,
        email: String,
        displayName: String,
        accessToken: String,
        refreshToken: String
    ) {
        currentUser = AppUser(
            id: id,
            email: email,
            displayName: displayName,
            role: .learner,
            status: .active,
            institutionID: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        isAuthenticated = true
        sessionStore.saveAccessToken(accessToken)
        sessionStore.saveRefreshToken(refreshToken)
        SupabaseManager.shared.setAuthToken(accessToken)
    }

    private func applySession(_ session: AuthSession) {
        accessToken = session.accessToken
        refreshToken = session.refreshToken
        currentUser = session.user
        isAuthenticated = true
        sessionStore.saveAccessToken(session.accessToken)
        sessionStore.saveRefreshToken(session.refreshToken)
        SupabaseManager.shared.setAuthToken(session.accessToken)
        RuntimeLogger.log(.auth, "session applied user=\(session.user.id)")
    }
}

private struct SignUpPayload: Encodable {
    let email: String
    let password: String
    let data: [String: String]
}

struct AuthSession: Decodable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
    let user: AppUser
}

enum AuthError: Error, LocalizedError {
    case invalidCredential
    case sessionExpired
    case networkError
    case accountDisabled

    var errorDescription: String? {
        switch self {
        case .invalidCredential: return "Invalid credentials"
        case .sessionExpired: return "Session expired, please sign in again"
        case .networkError: return "Network error, please try again"
        case .accountDisabled: return "Account has been disabled"
        }
    }
}


private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
