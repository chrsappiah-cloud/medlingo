import Foundation

protocol NetworkClientProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
    func request(_ endpoint: Endpoint) async throws
}

struct Endpoint {
    let path: String
    let method: HTTPMethod
    let body: Data?
    let queryItems: [URLQueryItem]?

    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case patch = "PATCH"
        case delete = "DELETE"
    }

    init(
        path: String,
        method: HTTPMethod = .get,
        body: Data? = nil,
        queryItems: [URLQueryItem]? = nil
    ) {
        self.path = path
        self.method = method
        self.body = body
        self.queryItems = queryItems
    }
}

final class NetworkClient: NetworkClientProtocol {
    private let session: URLSession
    private let baseURL: URL
    private var defaultHeaders: [String: String]
    private let tokenProvider: (() async -> String?)?
    var launchConfiguration: AppLaunchConfiguration

    init(
        baseURL: URL,
        tokenProvider: @escaping () async -> String?,
        session: URLSession = .shared,
        launchConfiguration: AppLaunchConfiguration = .shared
    ) {
        self.baseURL = baseURL
        self.tokenProvider = tokenProvider
        self.defaultHeaders = ["Content-Type": "application/json"]
        self.session = session
        self.launchConfiguration = launchConfiguration
    }

    init(
        baseURL: URL,
        defaultHeaders: [String: String] = [:],
        session: URLSession = .shared,
        launchConfiguration: AppLaunchConfiguration = .shared
    ) {
        self.baseURL = baseURL
        self.defaultHeaders = defaultHeaders
        self.tokenProvider = nil
        self.session = session
        self.launchConfiguration = launchConfiguration
    }

    func setHeader(_ key: String, value: String) {
        defaultHeaders[key] = value
    }

    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let data = try await performRequest(endpoint)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(T.self, from: data)
    }

    func request(_ endpoint: Endpoint) async throws {
        _ = try await performRequest(endpoint)
    }

    private func performRequest(_ endpoint: Endpoint) async throws -> Data {
        var components = URLComponents(url: baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: true)!
        components.queryItems = endpoint.queryItems

        var request = URLRequest(url: components.url!)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body

        for (key, value) in defaultHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }

        if let tokenProvider, let token = await tokenProvider() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if launchConfiguration.isOfflineNetwork {
            RuntimeLogger.log(.network, "blocked request offline path=\(endpoint.path)", level: RuntimeLogger.Level.error)
            throw NetworkError.transportError
        }

        RuntimeLogger.log(.network, "\(endpoint.method.rawValue) \(endpoint.path)")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            RuntimeLogger.log(.network, "HTTP \(httpResponse.statusCode) path=\(endpoint.path)", level: RuntimeLogger.Level.error)
            throw NetworkError.httpError(statusCode: httpResponse.statusCode, data: data)
        }

        return data
    }
}

enum NetworkError: Error, LocalizedError {
    case invalidResponse
    case httpError(statusCode: Int, data: Data)
    case decodingError(Error)
    case transportError

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid server response"
        case .httpError(let code, _):
            return "Server error (code \(code))"
        case .decodingError(let error):
            return "Data error: \(error.localizedDescription)"
        case .transportError:
            return "No internet connection"
        }
    }
}
