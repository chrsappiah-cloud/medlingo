import Foundation

@MainActor
final class SupabaseManager {
    static let shared = SupabaseManager()

    let projectURL: URL
    let anonKey: String
    let networkClient: NetworkClient
    let functionsClient: NetworkClient

    /// Returns false when placeholder/default credentials are still in use.
    var isConfigured: Bool {
        !Config.supabaseURL.contains("your-project") && !Config.supabaseAnonKey.contains("your-anon-key")
    }

    private init() {
        self.projectURL = URL(string: Config.supabaseURL)!
        self.anonKey = Config.supabaseAnonKey

        self.networkClient = NetworkClient(
            baseURL: URL(string: Config.supabaseURL)!.appendingPathComponent("rest/v1"),
            defaultHeaders: [
                "apikey": Config.supabaseAnonKey,
                "Content-Type": "application/json",
                "Prefer": "return=representation"
            ]
        )

        self.functionsClient = NetworkClient(
            baseURL: URL(string: Config.supabaseURL)!.appendingPathComponent("functions/v1"),
            defaultHeaders: [
                "apikey": Config.supabaseAnonKey,
                "Content-Type": "application/json"
            ]
        )
    }

    func setAuthToken(_ token: String) {
        networkClient.setHeader("Authorization", value: "Bearer \(token)")
        functionsClient.setHeader("Authorization", value: "Bearer \(token)")
    }

    func clearAuthToken() {
        networkClient.setHeader("Authorization", value: "Bearer \(anonKey)")
        functionsClient.setHeader("Authorization", value: "Bearer \(anonKey)")
    }
}
