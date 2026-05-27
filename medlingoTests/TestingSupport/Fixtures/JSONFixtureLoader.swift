import Foundation

private final class FixtureBundleToken {}

enum JSONFixtureLoader {
    static func data(named name: String, bundle: Bundle = Bundle(for: FixtureBundleToken.self)) -> Data {
        let url = bundle.url(forResource: name, withExtension: "json", subdirectory: "TestingSupport/Fixtures/JSON")
            ?? bundle.url(forResource: name, withExtension: "json", subdirectory: "Fixtures/JSON")
            ?? bundle.url(forResource: name, withExtension: "json")
        guard let url, let data = try? Data(contentsOf: url) else {
            fatalError("Missing fixture: \(name).json")
        }
        return data
    }

    static func decode<T: Decodable>(_ type: T.Type, from name: String) throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(type, from: data(named: name))
    }
}
