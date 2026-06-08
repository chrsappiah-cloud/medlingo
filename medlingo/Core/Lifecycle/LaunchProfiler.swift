import Foundation
import OSLog

/// OSSignposter-based cold-launch instrumentation.
/// Call `LaunchProfiler.end()` once the first meaningful screen is ready.
/// Instrument the interval in Xcode -> Product -> Profile -> Time Profiler.
@MainActor
enum LaunchProfiler {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "wcs.medlingo",
        category: "launch"
    )
    private static let signposter = OSSignposter(logger: logger)
    private static var state: OSSignpostIntervalState? = signposter.beginInterval("cold-launch")

    /// Mark the end of the cold-launch interval. This is intentionally idempotent:
    /// tests and scene transitions may route `.launched` more than once in one process.
    static func end() {
        guard let activeState = state else { return }
        signposter.endInterval("cold-launch", activeState)
        state = nil
    }
}
