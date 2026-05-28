import Foundation
@testable import medlingo

final class AnalyticsTrackerSpy: AnalyticsServiceProtocol {
    private(set) var trackedEvents: [AnalyticsEvent] = []
    private(set) var userProperties: [String: String] = [:]
    private(set) var flushCallCount = 0

    func track(_ event: AnalyticsEvent) {
        trackedEvents.append(event)
    }

    func setUserProperties(_ properties: [String: String]) {
        userProperties.merge(properties) { _, new in new }
    }

    func flush() {
        flushCallCount += 1
    }

    var lastEvent: AnalyticsEvent? { trackedEvents.last }
    var eventCount: Int { trackedEvents.count }

    func reset() {
        trackedEvents.removeAll()
        userProperties.removeAll()
        flushCallCount = 0
    }
}
