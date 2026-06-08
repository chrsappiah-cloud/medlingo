import Foundation
import Testing
@testable import medlingo

struct AegisTraceStandardsTests {
    private let manifestData = Data("""
    {
      "version": "1.0",
      "requirements": [
        {
          "id": "AUTH-SIGNIN-001",
          "feature": "Sign-in keeps learners recoverable after token refresh",
          "risk": "high",
          "layer": "contract",
          "tests": ["AuthServiceTests.signInWithEmail_whenSessionValid_authenticatesAndPersistsTokens"],
          "defects": [],
          "releaseStatus": "accepted"
        },
        {
          "id": "LEARN-PROGRESS-001",
          "feature": "Learning progression remains deterministic offline",
          "risk": "medium",
          "layer": "flow",
          "tests": ["DataMiddlewareTests.loadInitialData_whenChaptersFetchFails_usesFallback"],
          "defects": [],
          "releaseStatus": "accepted"
        },
        {
          "id": "API-DECODING-001",
          "feature": "API clients surface malformed payloads as decoding failures",
          "risk": "high",
          "layer": "boundary",
          "tests": ["NetworkClientBehaviorTests.request_whenMalformedJSON_throwsDecodingError"],
          "defects": [],
          "releaseStatus": "accepted"
        },
        {
          "id": "NETWORK-OFFLINE-001",
          "feature": "Poor-network launch remains navigable",
          "risk": "critical",
          "layer": "risk",
          "tests": ["ReviewFlowTests.testOfflineLaunch_appRemainsNavigable"],
          "defects": [],
          "releaseStatus": "watch"
        },
        {
          "id": "RELEASE-SMOKE-001",
          "feature": "Top learner journey reaches Learn and Practice",
          "risk": "high",
          "layer": "acceptance",
          "tests": ["SmokeTests"],
          "defects": [],
          "releaseStatus": "accepted"
        }
      ]
    }
    """.utf8)

    @Test func traceMatrix_coversAllAegisTraceLayers() throws {
        let manifest = try AegisTraceMatrix.decode(manifestData)

        #expect(manifest.version == "1.0")
        #expect(manifest.layersCovered == Set(AegisTraceLayer.allCases))
        #expect(manifest.blockedRequirements.isEmpty)
        AegisTraceKit.expectTraceIDs(manifest.requirements)
    }

    @Test func deterministicClockAndUUIDInjector_makeAsyncTestsPredictable() {
        let firstDate = Date(timeIntervalSince1970: 10)
        let secondDate = Date(timeIntervalSince1970: 20)
        let clock = AegisTraceKit.DeterministicClock(dates: [firstDate, secondDate])
        let uuid = UUID(uuidString: "11111111-1111-1111-1111-111111111111")!
        let injector = AegisTraceKit.UUIDInjector(values: [uuid])

        #expect(clock.now() == firstDate)
        #expect(clock.now() == secondDate)
        #expect(injector.next() == uuid)
        #expect(injector.next().uuidString == "00000000-0000-0000-0000-000000000001")
    }

    @Test func labScenario_producesStructuredEvidenceForReleaseReport() throws {
        let manifest = try AegisTraceMatrix.decode(manifestData)
        let clock = AegisTraceKit.DeterministicClock(dates: [
            Date(timeIntervalSince1970: 100),
            Date(timeIntervalSince1970: 101)
        ])
        let scenario = AegisTraceLab.Scenario(
            id: "NETWORK-OFFLINE-001-slow-network-duplicate-tap",
            layer: .risk,
            risk: .critical,
            seededAccount: "learner-demo",
            offlineMode: true,
            timeTravel: Date(timeIntervalSince1970: 100),
            hostilePayloadName: "duplicate-tap"
        )

        let result = AegisTraceLab.run(scenario, clock: clock)
        let report = AegisTraceReports.markdown(
            title: "WCS AegisTrace Release Report",
            manifest: manifest,
            labResults: [result]
        )

        #expect(result.passed)
        #expect(result.events.count == 2)
        #expect(report.contains("Coverage Summary"))
        #expect(report.contains("risk: covered"))
        #expect(report.contains("Accepted for covered requirements."))
    }

    @Test func mockNetworkClient_recordsRequestsForBoundaryTests() async throws {
        struct Payload: Codable, Equatable {
            let ok: Bool
        }
        let data = try JSONEncoder().encode(Payload(ok: true))
        let client = AegisTraceKit.MockNetworkClient(responseData: data)

        let payload: Payload = try await client.request(Endpoint(path: "health", method: .get))

        #expect(payload == Payload(ok: true))
        #expect(client.requests.count == 1)
        #expect(client.requests.first?.path == "health")
    }
}
