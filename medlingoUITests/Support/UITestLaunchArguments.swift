import Foundation

enum UITestLaunchArguments {
    static let uiTestMode = "-UITesting"
    static let offline = "-mockNetwork"
    static let offlineValue = "offline"
    static let seedExpiredToken = "-seedExpiredToken"
    static let seedCreatorRole = "-seedCreatorRole"

    static func standardSmoke() -> [String] { [uiTestMode] }

    static func offlineLaunch() -> [String] {
        [uiTestMode, offline, offlineValue]
    }

    static func aiVideoGeneration() -> [String] {
        [uiTestMode, seedCreatorRole, "-mockAIGeneration"]
    }
}
