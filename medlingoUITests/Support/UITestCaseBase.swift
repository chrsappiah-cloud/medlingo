import XCTest

class UITestCaseBase: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
    }

    func launchApp(arguments: [String] = UITestLaunchArguments.standardSmoke()) {
        app.launchArguments = arguments
        app.launch()
    }

    @MainActor
    func tapTab(_ name: String, file: StaticString = #file, line: UInt = #line) {
        let tabBar = app.tabBars.firstMatch
        let directTab = tabBar.buttons[name]

        if directTab.waitForExistence(timeout: 2), directTab.isHittable {
            directTab.tap()
            return
        }

        let more = tabBar.buttons["More"]
        if more.waitForExistence(timeout: 5) {
            more.tap()
            let overflowButton = app.buttons[name]
            if overflowButton.waitForExistence(timeout: 5) {
                overflowButton.tap()
                return
            }
            let overflowCell = app.cells.containing(NSPredicate(format: "label CONTAINS[c] %@", name)).firstMatch
            if overflowCell.waitForExistence(timeout: 5) {
                overflowCell.tap()
                return
            }
        }

        XCTAssertTrue(false, "Tab '\(name)' not found in tab bar or More", file: file, line: line)
    }

    @MainActor
    func tabIsReachable(_ name: String) -> Bool {
        let tabBar = app.tabBars.firstMatch
        if tabBar.buttons[name].exists { return true }
        guard tabBar.buttons["More"].exists else { return false }

        tabBar.buttons["More"].tap()
        defer {
            if tabBar.buttons["Learn"].exists {
                tabBar.buttons["Learn"].tap()
            }
        }

        return app.buttons[name].waitForExistence(timeout: 2)
            || app.cells.containing(NSPredicate(format: "label CONTAINS[c] %@", name)).firstMatch.exists
    }
}
