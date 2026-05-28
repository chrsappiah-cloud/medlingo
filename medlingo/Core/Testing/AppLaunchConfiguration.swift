import Foundation

/// Parses launch arguments and environment flags for UI tests, integration tests, and ARC Shield scenarios.
struct AppLaunchConfiguration: Sendable {
    static let shared = AppLaunchConfiguration()

    let arguments: [String]

    var isUITestMode: Bool {
        arguments.contains("-UITesting") || arguments.contains("-uiTestMode")
    }

    var isOfflineNetwork: Bool {
        arguments.contains(where: { $0 == "-mockNetwork" && nextValue(after: $0) == "offline" })
            || arguments.contains("-mockNetworkOffline")
    }

    var storeKitScenario: StoreKitTestScenario? {
        if arguments.contains("-mockStoreKit") {
            let value = nextValue(after: "-mockStoreKit") ?? "productsFailure"
            return StoreKitTestScenario(rawValue: value) ?? .productsFailure
        }
        return nil
    }

    var permissionScenario: PermissionScenario? {
        if arguments.contains("-mockPermissions") {
            let value = nextValue(after: "-mockPermissions") ?? "deniedMicrophone"
            return PermissionScenario(rawValue: value)
        }
        return nil
    }

    var seedsEmptyDatabase: Bool { arguments.contains("-seedEmptyDatabase") }
    var seedsExpiredToken: Bool { arguments.contains("-seedExpiredToken") }
    var seedsMigratedState: Bool { arguments.contains("-seedMigratedState") }
    var seedsCreatorRole: Bool { arguments.contains("-seedCreatorRole") }
    var forcesDemoAIGeneration: Bool {
        arguments.contains("-mockAIGeneration") || (isUITestMode && seedsCreatorRole)
    }
    var skipsOnboarding: Bool { isUITestMode }
    /// Presents Subscription paywall on launch for App Store IAP review screenshots.
    var showsSubscriptionForReview: Bool { arguments.contains("-subscriptionReviewScreenshot") }

    public init(arguments: [String] = ProcessInfo.processInfo.arguments) {
        self.arguments = arguments
    }

    private func nextValue(after flag: String) -> String? {
        guard let index = arguments.firstIndex(of: flag), index + 1 < arguments.count else {
            return nil
        }
        return arguments[index + 1]
    }
}

enum StoreKitTestScenario: String, Sendable {
    case productsSuccess
    case productsFailure
    case purchaseCancelled
    case purchaseSuccess
    case purchasePending
    case restoreSuccess
    case restoreEmpty
    case offline
}

enum PermissionScenario: String, Sendable {
    case notRequested
    case granted
    case deniedMicrophone
    case deniedCamera
    case restricted
    case limited
}
