import Testing
import Foundation
@testable import medlingo

@Suite(.serialized)
struct NetworkClientBehaviorTests {
    private func makeClient(handler: @escaping (URLRequest) throws -> (HTTPURLResponse, Data)) -> NetworkClient {
        MockURLProtocol.requestHandler = handler
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        return NetworkClient(
            baseURL: URL(string: "https://api.test.medlingo")!,
            session: session
        )
    }

    @Test func request_whenValidJSON_decodesResponse() async throws {
        let sample = Chapter(
            id: UUID(),
            number: 1,
            title: "Foundations",
            summary: "s",
            estimatedMinutes: 30,
            coverArtURL: nil,
            accentColorHex: "fff",
            prerequisiteIDs: [],
            unlockRule: .free
        )
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let payload = try encoder.encode([sample])

        let client = makeClient { request in
            #expect(request.httpMethod == "GET")
            #expect(request.url?.path.contains("chapters") == true)
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, payload)
        }

        let chapters: [Chapter] = try await client.request(Endpoint(path: "chapters", method: .get))
        #expect(chapters.count == 1)
        #expect(chapters[0].title == "Foundations")
    }

    @Test func request_when401_throwsHttpError() async {
        let client = makeClient { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 401, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }

        await #expect(throws: NetworkError.self) {
            let _: [Chapter] = try await client.request(Endpoint(path: "chapters", method: .get))
        }
    }

    @Test func request_when500_throwsHttpError() async {
        let client = makeClient { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!
            return (response, Data("error".utf8))
        }

        await #expect(throws: NetworkError.self) {
            let _: [Chapter] = try await client.request(Endpoint(path: "chapters", method: .get))
        }
    }

    @Test func request_whenMalformedJSON_throwsDecodingError() async {
        let client = makeClient { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data("{not-json".utf8))
        }

        await #expect(throws: (any Error).self) {
            let _: [Chapter] = try await client.request(Endpoint(path: "chapters", method: .get))
        }
    }

    @Test func request_whenTransportError_propagates() async {
        let client = makeClient { _ in throw URLError(.notConnectedToInternet) }

        await #expect(throws: URLError.self) {
            let _: [Chapter] = try await client.request(Endpoint(path: "chapters", method: .get))
        }
    }
}
