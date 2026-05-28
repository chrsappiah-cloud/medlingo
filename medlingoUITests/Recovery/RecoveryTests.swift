import XCTest

final class RecoveryTests: UITestCaseBase {

    @MainActor
    func testBackgroundThenForeground_appSurvives() throws {
        launchApp()
        XCTAssertTrue(app.staticTexts["Medlingo"].waitForExistence(timeout: 5))

        XCUIDevice.shared.press(.home)
        app.activate()

        XCTAssertTrue(app.staticTexts["Medlingo"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testExpiredTokenSeed_launchStillShowsAccount() throws {
        launchApp(arguments: [UITestLaunchArguments.uiTestMode, UITestLaunchArguments.seedExpiredToken])
        tapTab("Account")
        XCTAssertTrue(app.navigationBars["Account"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Christopher"].waitForExistence(timeout: 3))
    }

    @MainActor
    func testPracticeLab_afterTabSwitch_remainsReachable() throws {
        launchApp()
        tapTab("Practice")
        XCTAssertTrue(app.navigationBars["Practice Lab"].waitForExistence(timeout: 3))
        tapTab("Learn")
        tapTab("Practice")
        XCTAssertTrue(app.staticTexts["Practice Modes"].waitForExistence(timeout: 3))
    }
}
