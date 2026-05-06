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

    var token: String? { accessToken }

    func signInWithApple(credential: ASAuthorizationAppleIDCredential) async throws {
        isLoading = true
        defer { isLoading = false }

        guard let identityToken = credential.identityToken,
              let tokenString = String(data: identityToken, encoding: .utf8) else {
            throw AuthError.invalidCredential
        }

        // Send token to Supabase for verification and session creation
        // TODO: Implement Supabase Apple auth flow
        _ = tokenString
    }

    func signInWithEmail(email: String, password: String) async throws {
        isLoading = true
        do { isLoading = false }
    }

    func signUp(email: String, password: String, displayName: String) async throws {
        isLoading = true
        do { isLoading = false }
    }

    func signOut() async throws {
        currentUser = nil
        accessToken = nil
        isAuthenticated = false
    }

    func refreshSession() async throws {
        // TODO: Implement token refresh
    }

    func deleteAccount() async throws {
        // TODO: Implement account deletion
    }
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
