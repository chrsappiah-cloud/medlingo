import Foundation
@testable import medlingo

final class MockNetworkClient: NetworkClientProtocol, @unchecked Sendable {
    var requestHandler: ((Endpoint) throws -> Data)?

    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let data = try requestHandler?(endpoint) ?? Data()
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(T.self, from: data)
    }

    func request(_ endpoint: Endpoint) async throws {
        _ = try requestHandler?(endpoint) ?? Data()
    }
}
