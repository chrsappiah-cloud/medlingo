import Testing
@testable import medlingo

struct NetworkContractTests {
    @Test func endpoint_contract_matchesHTTPVerbRawValues() {
        let contract: [(Endpoint.HTTPMethod, String)] = [
            (.get, "GET"),
            (.post, "POST"),
            (.put, "PUT"),
            (.patch, "PATCH"),
            (.delete, "DELETE"),
        ]
        for (method, expected) in contract {
            #expect(method.rawValue == expected)
        }
    }
}
