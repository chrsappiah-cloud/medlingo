import Foundation

protocol ClockProtocol: Sendable {
    func now() -> Date
}

struct LiveClock: ClockProtocol {
    func now() -> Date { Date() }
}

struct TestClock: ClockProtocol {
    var fixedDate: Date

    init(fixedDate: Date = Date(timeIntervalSince1970: 1_700_000_000)) {
        self.fixedDate = fixedDate
    }

    func now() -> Date { fixedDate }
}
