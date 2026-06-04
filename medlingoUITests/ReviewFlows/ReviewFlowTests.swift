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
    func testAccount_cleanLaunchShowsGuestAndNoSignOut() throws {
        launchApp()
        tapTab("Account")
        XCTAssertTrue(app.staticTexts["Guest learner"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["No account signed in"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["sign-out-button"].exists)
    }

    @MainActor
    func testAccount_signOutClearsAuthenticatedSession() throws {
        launchApp(arguments: [
            UITestLaunchArguments.uiTestMode,
            UITestLaunchArguments.seedAuthenticatedSession
        ])
        tapTab("Account")
        XCTAssertTrue(app.staticTexts["Review Learner"].waitForExistence(timeout: 5))
        let signOut = app.buttons["sign-out-button"]
        if !signOut.waitForExistence(timeout: 3) { app.collectionViews.firstMatch.swipeUp() }
        XCTAssertTrue(signOut.waitForExistence(timeout: 8))
        signOut.tap()
        XCTAssertTrue(app.alerts["Account"].waitForExistence(timeout: 5))
        app.alerts["Account"].buttons["OK"].tap()
        XCTAssertTrue(app.staticTexts["Guest learner"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["sign-out-button"].exists)
    }
}
