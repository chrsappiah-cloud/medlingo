import XCTest

final class ReviewFlowTests: UITestCaseBase {

    @MainActor
    func testFirstLaunch_cleanInstall_showsLearnHome() throws {
        launchApp(arguments: UITestLaunchArguments.standardSmoke())
        XCTAssertTrue(app.staticTexts["Medlingo"].waitForExistence(timeout: 5))
        XCTAssertFalse(tabIsReachable("Studio"), "Studio should be hidden for learner role")
    }

    @MainActor
    func testOfflineLaunch_appRemainsNavigable() throws {
        launchApp(arguments: UITestLaunchArguments.offlineLaunch())
        tapTab("Practice")
        XCTAssertTrue(app.navigationBars["Practice Lab"].waitForExistence(timeout: 5))
        tapTab("Learn")
        XCTAssertTrue(app.staticTexts["Medlingo"].waitForExistence(timeout: 3))
    }

    @MainActor
    func testSubscriptionPath_upgradeControlExists() throws {
        launchApp()
        tapTab("Account")
        XCTAssertTrue(app.staticTexts["Premium Plan"].waitForExistence(timeout: 5))
        app.staticTexts["Premium Plan"].tap()

        XCTAssertTrue(app.navigationBars["Subscription"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Available Plans"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Upgrade"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testSubscriptionPath_whenProductsFail_showsUnavailableMessage() throws {
        launchApp(arguments: UITestLaunchArguments.subscriptionProductsFailure())
        XCTAssertTrue(app.staticTexts["Medlingo"].waitForExistence(timeout: 8))
        tapTab("Account")
        XCTAssertTrue(app.navigationBars["Account"].waitForExistence(timeout: 8))
        app.staticTexts["Premium Plan"].tap()

        XCTAssertTrue(app.navigationBars["Subscription"].waitForExistence(timeout: 5))
        let inlineError = app.staticTexts["subscription-load-error"]
        let alertError = app.alerts["Purchase Error"]
        XCTAssertTrue(
            inlineError.waitForExistence(timeout: 8) || alertError.waitForExistence(timeout: 8),
            "Expected subscription load error message or alert"
        )
    }

    @MainActor
    func testRestorePurchases_buttonExistsAndIsTappable() throws {
        launchApp(arguments: UITestLaunchArguments.restorePurchasesSuccess())
        tapTab("Account")
        let restore = app.buttons["Restore Purchases"]
        XCTAssertTrue(restore.waitForExistence(timeout: 5))
        restore.tap()
        XCTAssertTrue(app.navigationBars["Account"].waitForExistence(timeout: 3))
    }

    @MainActor
    func testAccount_signOutButtonReachable() throws {
        launchApp()
        tapTab("Account")
        let signOut = app.buttons["sign-out-button"]
        if !signOut.waitForExistence(timeout: 3) {
            app.collectionViews.firstMatch.swipeUp()
            app.collectionViews.firstMatch.swipeUp()
        }
        XCTAssertTrue(signOut.waitForExistence(timeout: 8))
    }
}
