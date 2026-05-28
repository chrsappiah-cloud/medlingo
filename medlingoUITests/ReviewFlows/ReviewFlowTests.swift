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
