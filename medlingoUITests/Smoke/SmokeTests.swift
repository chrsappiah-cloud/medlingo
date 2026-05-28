import XCTest

final class SmokeTests: UITestCaseBase {

    @MainActor
    func testLaunch_navigatesMainTabsWithoutCrash() throws {
        launchApp()
        XCTAssertTrue(app.tabBars.firstMatch.exists)

        for name in ["Learn", "Practice", "Collection", "Sessions"] {
            XCTAssertTrue(app.tabBars.buttons[name].exists, "\(name) tab should exist")
        }
        XCTAssertTrue(tabIsReachable("Progress"))
        XCTAssertTrue(tabIsReachable("Account"))
    }

    @MainActor
    func testHomeScreen_criticalContentVisible() throws {
        launchApp()
        XCTAssertTrue(app.staticTexts["Medlingo"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Continue Learning"].exists)
        XCTAssertTrue(app.buttons["Resume"].waitForExistence(timeout: 3))
    }

    @MainActor
    func testTabNavigation_criticalScreensOpen() throws {
        launchApp()

        tapTab("Practice")
        XCTAssertTrue(app.navigationBars["Practice Lab"].waitForExistence(timeout: 3))

        tapTab("Sessions")
        XCTAssertTrue(app.navigationBars["Sessions"].waitForExistence(timeout: 3))

        tapTab("Progress")
        XCTAssertTrue(app.navigationBars["Progress"].waitForExistence(timeout: 3))

        tapTab("Account")
        XCTAssertTrue(app.navigationBars["Account"].waitForExistence(timeout: 3))
    }
}
