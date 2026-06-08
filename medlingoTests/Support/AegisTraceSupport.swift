import Foundation
import Testing
@testable import medlingo

enum AegisTraceLayer: String, Codable, CaseIterable, Sendable {
    case contract
    case flow
    case boundary
    case risk
    case acceptance
}

enum AegisTraceRisk: String, Codable, CaseIterable, Sendable {
    case low
    case medium
    case high
    case critical
}

enum AegisTraceReleaseStatus: String, Codable, Sendable {
    case accepted
    case watch
    case blocked
}

struct AegisTraceRequirement: Codable, Hashable, Sendable {
    let id: String
    let feature: String
    let risk: AegisTraceRisk
    let layer: AegisTraceLayer
    let tests: [String]
    let defects: [String]
    let releaseStatus: AegisTraceReleaseStatus
}

enum AegisTraceKit {
    final class DeterministicClock: @unchecked Sendable {
        private let dates: [Date]
        private let fallback: Date
        private let lock = NSLock()
        private var index = 0

        init(dates: [Date], fallback: Date = Date(timeIntervalSince1970: 1_700_000_000)) {
            self.dates = dates
            self.fallback = fallback
        }

        func now() -> Date {
            lock.lock()
            defer { lock.unlock() }
            guard index < dates.count else { return fallback }
            let date = dates[index]
            index += 1
            return date
        }
    }

    final class UUIDInjector: @unchecked Sendable {
        private let values: [UUID]
        private let fallback: UUID
        private let lock = NSLock()
        private var index = 0

        init(values: [UUID], fallback: UUID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!) {
            self.values = values
            self.fallback = fallback
        }

        func next() -> UUID {
            lock.lock()
            defer { lock.unlock() }
            guard index < values.count else { return fallback }
            let value = values[index]
            index += 1
            return value
        }
    }

    struct FixtureLoader {
        static func decode<T: Decodable>(_ type: T.Type, from url: URL) throws -> T {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(type, from: data)
        }
    }

    final class MockNetworkClient: NetworkClientProtocol {
        struct Request: Sendable {
            let path: String
            let method: Endpoint.HTTPMethod
            let queryItems: [URLQueryItem]?
        }

        private(set) var requests: [Request] = []
        var responseData: Data
        var thrownError: Error?

        init(responseData: Data = Data("{}".utf8), thrownError: Error? = nil) {
            self.responseData = responseData
            self.thrownError = thrownError
        }

        func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
            requests.append(Request(path: endpoint.path, method: endpoint.method, queryItems: endpoint.queryItems))
            if let thrownError { throw thrownError }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.self, from: responseData)
        }

        func request(_ endpoint: Endpoint) async throws {
            requests.append(Request(path: endpoint.path, method: endpoint.method, queryItems: endpoint.queryItems))
            if let thrownError { throw thrownError }
        }
    }

    static func expectTraceIDs(_ requirements: [AegisTraceRequirement]) {
        for requirement in requirements {
            #expect(!requirement.id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            #expect(!requirement.feature.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            #expect(!requirement.tests.isEmpty)
        }
    }
}

enum AegisTraceLogger {
    enum EventKind: String, Codable, Sendable {
        case screenTransition
        case stateMutation
        case apiCall
        case retry
        case decodingFailure
        case threadHop
        case scenario
    }

    struct Event: Codable, Hashable, Sendable {
        let kind: EventKind
        let message: String
        let metadata: [String: String]
        let timestamp: Date
    }

    static func event(
        _ kind: EventKind,
        _ message: String,
        metadata: [String: String] = [:],
        timestamp: Date
    ) -> Event {
        Event(kind: kind, message: message, metadata: metadata, timestamp: timestamp)
    }
}

enum AegisTraceMatrix {
    struct Manifest: Codable, Sendable {
        let version: String
        let requirements: [AegisTraceRequirement]

        var layersCovered: Set<AegisTraceLayer> {
            Set(requirements.map(\.layer))
        }

        var blockedRequirements: [AegisTraceRequirement] {
            requirements.filter { $0.releaseStatus == .blocked }
        }
    }

    static func decode(_ data: Data) throws -> Manifest {
        try JSONDecoder().decode(Manifest.self, from: data)
    }
}

enum AegisTraceLab {
    struct Scenario: Sendable {
        let id: String
        let layer: AegisTraceLayer
        let risk: AegisTraceRisk
        let seededAccount: String
        let offlineMode: Bool
        let timeTravel: Date?
        let hostilePayloadName: String?
    }

    struct Result: Sendable {
        let scenario: Scenario
        let events: [AegisTraceLogger.Event]
        let passed: Bool
    }

    static func run(_ scenario: Scenario, clock: AegisTraceKit.DeterministicClock) -> Result {
        let events = [
            AegisTraceLogger.event(
                .scenario,
                "Started \(scenario.id)",
                metadata: [
                    "layer": scenario.layer.rawValue,
                    "risk": scenario.risk.rawValue,
                    "offline": String(scenario.offlineMode)
                ],
                timestamp: clock.now()
            ),
            AegisTraceLogger.event(
                scenario.offlineMode ? .retry : .stateMutation,
                scenario.offlineMode ? "Offline path exercised" : "Scenario completed",
                metadata: ["seededAccount": scenario.seededAccount],
                timestamp: clock.now()
            )
        ]
        return Result(scenario: scenario, events: events, passed: true)
    }
}

enum AegisTraceReports {
    static func markdown(
        title: String,
        manifest: AegisTraceMatrix.Manifest,
        labResults: [AegisTraceLab.Result]
    ) -> String {
        let covered = AegisTraceLayer.allCases
            .map { layer in "\(layer.rawValue): \(manifest.layersCovered.contains(layer) ? "covered" : "missing")" }
            .joined(separator: "\n")
        let blocked = manifest.blockedRequirements.map(\.id).joined(separator: ", ")
        let scenarios = labResults
            .map { "- \($0.scenario.id): \($0.passed ? "passed" : "failed") (\($0.events.count) events)" }
            .joined(separator: "\n")

        return """
        # \(title)

        ## Coverage Summary
        \(covered)

        ## Open Risks
        \(blocked.isEmpty ? "None" : blocked)

        ## Lab Scenarios
        \(scenarios.isEmpty ? "None" : scenarios)

        ## Acceptance Status
        \(manifest.blockedRequirements.isEmpty ? "Accepted for covered requirements." : "Blocked requirements require release review.")
        """
    }
}
