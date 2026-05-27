import Foundation
@testable import medlingo

final class MockNetworkClient: NetworkClientProtocol, @unchecked Sendable {
    var requestHandler: ((Endpoint) throws -> Data)?
    var lastEndpoint: Endpoint?

    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        lastEndpoint = endpoint
        let data = try resolvedData(for: endpoint)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }

    func request(_ endpoint: Endpoint) async throws {
        lastEndpoint = endpoint
        _ = try resolvedData(for: endpoint)
    }

    private func resolvedData(for endpoint: Endpoint) throws -> Data {
        if let requestHandler {
            return try requestHandler(endpoint)
        }
        throw NetworkError.transportError
    }
}
