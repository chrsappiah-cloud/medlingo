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
        if tapTopTabStrip(name) { return }

        // iOS 26+: tab bar uses a different accessibility container — search all buttons by label.
        let labelPred = NSPredicate(format: "label == %@", name)
        let anyButton = app.buttons.matching(labelPred).firstMatch
        if anyButton.waitForExistence(timeout: 8), anyButton.isHittable {
            anyButton.tap()
            return
        } else if anyButton.exists {
            anyButton.tap()
            return
        }

        // Legacy iOS tab bar (< iOS 26)
        let tabBar = app.tabBars.firstMatch
        if tabBar.waitForExistence(timeout: 2) {
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
        }

        XCTAssertTrue(false, "Tab '\(name)' not found in tab bar or More", file: file, line: line)
    }

    @MainActor
    func tabIsReachable(_ name: String) -> Bool {
        if canTapTopTabStrip(name) { return true }

        // iOS 26+: search all buttons by label.
        let labelPred = NSPredicate(format: "label == %@", name)
        let candidate = app.buttons.matching(labelPred).firstMatch
        if candidate.waitForExistence(timeout: 5) { return true }

        // Legacy iOS tab bar fallback.
        let tabBar = app.tabBars.firstMatch
        guard tabBar.waitForExistence(timeout: 2) else { return false }
        if tabBar.buttons[name].exists { return true }
        guard tabBar.buttons["More"].exists else { return false }

        tabBar.buttons["More"].tap()
        defer {
            let learnPred = NSPredicate(format: "label == 'Learn'")
            app.buttons.matching(learnPred).firstMatch.tap()
        }

        return app.buttons[name].waitForExistence(timeout: 2)
            || app.cells.containing(NSPredicate(format: "label CONTAINS[c] %@", name)).firstMatch.exists
    }

    @MainActor
    private func tapTopTabStrip(_ name: String) -> Bool {
        guard let coordinate = topTabCoordinate(for: name) else { return false }
        coordinate.tap()
        return true
    }

    @MainActor
    private func canTapTopTabStrip(_ name: String) -> Bool {
        topTabCoordinate(for: name) != nil
    }

    @MainActor
    private func topTabCoordinate(for name: String) -> XCUICoordinate? {
        let window = app.windows.firstMatch
        guard window.waitForExistence(timeout: 1), window.frame.width > 700 else {
            return nil
        }

        let xOffsets: [String: CGFloat] = [
            "Learn": 0.25,
            "Practice": 0.33,
            "Collection": 0.44,
            "Sessions": 0.55,
            "Progress": 0.66,
            "Account": 0.77,
        ]

        guard let x = xOffsets[name] else {
            return nil
        }

        return window.coordinate(withNormalizedOffset: CGVector(dx: x, dy: 0.04))
    }
}
