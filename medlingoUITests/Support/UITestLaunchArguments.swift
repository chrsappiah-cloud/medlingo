import Foundation

enum UITestLaunchArguments {
    static let uiTestMode = "-UITesting"
    static let offline = "-mockNetwork"
    static let offlineValue = "offline"
    static let productsFailure = "-mockStoreKit"
    static let productsFailureValue = "productsFailure"
    static let seedExpiredToken = "-seedExpiredToken"
    static let restoreSuccess = "-mockStoreKit"
    static let restoreSuccessValue = "restoreSuccess"

    static func standardSmoke() -> [String] { [uiTestMode] }

    static func offlineLaunch() -> [String] {
        [uiTestMode, offline, offlineValue]
    }

    static func subscriptionProductsFailure() -> [String] {
        [uiTestMode, productsFailure, productsFailureValue]
    }

    static func restorePurchasesSuccess() -> [String] {
        [uiTestMode, restoreSuccess, restoreSuccessValue]
    }
}
