import Foundation

protocol SessionStoreProtocol: Sendable {
    func loadRefreshToken() -> String?
    func saveRefreshToken(_ token: String?)
    func loadAccessToken() -> String?
    func saveAccessToken(_ token: String?)
    func clear()
}

final class UserDefaultsSessionStore: SessionStoreProtocol, @unchecked Sendable {
    private let defaults: UserDefaults
    private let refreshKey = "arc.session.refreshToken"
    private let accessKey = "arc.session.accessToken"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadRefreshToken() -> String? {
        defaults.string(forKey: refreshKey)
    }

    func saveRefreshToken(_ token: String?) {
        if let token {
            defaults.set(token, forKey: refreshKey)
        } else {
            defaults.removeObject(forKey: refreshKey)
        }
    }

    func loadAccessToken() -> String? {
        defaults.string(forKey: accessKey)
    }

    func saveAccessToken(_ token: String?) {
        if let token {
            defaults.set(token, forKey: accessKey)
        } else {
            defaults.removeObject(forKey: accessKey)
        }
    }

    func clear() {
        defaults.removeObject(forKey: refreshKey)
        defaults.removeObject(forKey: accessKey)
    }
}

final class InMemorySessionStore: SessionStoreProtocol, @unchecked Sendable {
    private var refreshToken: String?
    private var accessToken: String?

    func loadRefreshToken() -> String? { refreshToken }
    func saveRefreshToken(_ token: String?) { refreshToken = token }
    func loadAccessToken() -> String? { accessToken }
    func saveAccessToken(_ token: String?) { accessToken = token }
    func clear() {
        refreshToken = nil
        accessToken = nil
    }
}
