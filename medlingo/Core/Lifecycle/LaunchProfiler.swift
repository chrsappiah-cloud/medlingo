import OSLog

/// OSSignposter-based cold-launch instrumentation.
/// Call `LaunchProfiler.end()` once the first meaningful screen is ready.
/// Instrument the interval in Xcode → Product → Profile → Time Profiler.
enum LaunchProfiler {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "wcs.medlingo",
        category: "launch"
    )
    private static let signposter = OSSignposter(logger: logger)
    private static let state = signposter.beginInterval("cold-launch")

    /// Mark the end of the cold-launch interval.
    static func end() {
        signposter.endInterval("cold-launch", state)
    }
}
