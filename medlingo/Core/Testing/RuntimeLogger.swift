import Foundation
import os

/// ARC Shield Runtime Probe — structured logging for launch, auth, network, purchases, and migrations.
enum RuntimeLogger {
    enum Category: String {
        case lifecycle = "app.lifecycle"
        case auth = "auth.session"
        case network = "network.requests"
        case permissions = "permissions"
        case deepLink = "deepLink"
        case migration = "persistence.migration"
    }

    private static let subsystem = Bundle.main.bundleIdentifier ?? "wcs.medlingo"

    enum Level {
        case info
        case debug
        case error
        case fault
    }

    static func log(
        _ category: Category,
        _ message: String,
        level: Level = .info,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let logger = Logger(subsystem: subsystem, category: category.rawValue)
        let location = "\((file as NSString).lastPathComponent):\(line) \(function)"
        switch level {
        case .debug:
            logger.debug("\(message, privacy: .public) [\(location, privacy: .public)]")
        case .error:
            logger.error("\(message, privacy: .public) [\(location, privacy: .public)]")
        case .fault:
            logger.fault("\(message, privacy: .public) [\(location, privacy: .public)]")
        case .info:
            logger.info("\(message, privacy: .public) [\(location, privacy: .public)]")
        }
    }

    static var lastScreenBreadcrumb: String = "launch"

    static func breadcrumb(_ screen: String) {
        lastScreenBreadcrumb = screen
        log(.lifecycle, "screen=\(screen)")
    }
}

protocol LoggerProtocol: Sendable {
    func info(_ message: String)
    func error(_ message: String)
}

struct RuntimeLoggerAdapter: LoggerProtocol {
    let category: RuntimeLogger.Category

    func info(_ message: String) {
        RuntimeLogger.log(category, message)
    }

    func error(_ message: String) {
        RuntimeLogger.log(category, message, level: RuntimeLogger.Level.error)
    }
}
