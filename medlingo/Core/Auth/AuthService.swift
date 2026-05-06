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

    var token: String? { accessToken }

    init(client: NetworkClientProtocol? = nil) {
        self.client = client ?? SupabaseManager.shared.networkClient
    }

    func signInWithApple(credential: ASAuthorizationAppleIDCredential) async throws {
        isLoading = true
        defer { isLoading = false }

        guard let identityToken = credential.identityToken,
              let tokenString = String(data: identityToken, encoding: .utf8) else {
            throw AuthError.invalidCredential
        }

        let payload = try JSONEncoder().encode([
            "provider": "apple",
            "id_token": tokenString
        ])

        let session: AuthSession = try await client.request(Endpoint(
            path: "auth/v1/token",
            method: .post,
            body: payload,
            queryItems: [URLQueryItem(name: "grant_type", value: "id_token")]
        ))

        applySession(session)
    }

    func signInWithEmail(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }

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
        if accessToken != nil {
            try? await client.request(Endpoint(path: "auth/v1/logout", method: .post))
        }
        currentUser = nil
        accessToken = nil
        refreshToken = nil
        isAuthenticated = false
        SupabaseManager.shared.clearAuthToken()
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
        SupabaseManager.shared.clearAuthToken()
    }

    private func applySession(_ session: AuthSession) {
        accessToken = session.accessToken
        refreshToken = session.refreshToken
        currentUser = session.user
        isAuthenticated = true
        SupabaseManager.shared.setAuthToken(session.accessToken)
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
