import XCTest

/// Captures App Store distribution screenshots on a 6.7" Pro Max simulator (1290×2796).
/// Run via `scripts/capture-distribution-screenshots.sh`.
final class DistributionScreenshotTests: XCTestCase {

    private let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["-UITesting"]
        app.launch()
    }

    private static var defaultOutputDirectory: String {
        NSTemporaryDirectory() + "medlingo-distribution-screenshots"
    }

    @MainActor
    func testCaptureDistributionScreenshots() throws {
        let outputDir = Self.resolveOutputDirectory()
        try FileManager.default.createDirectory(atPath: outputDir, withIntermediateDirectories: true)

        capture(name: "01-learn-home", outputDir: outputDir)

        tapTab("Practice")
        XCTAssertTrue(app.navigationBars["Practice Lab"].waitForExistence(timeout: 5))
        capture(name: "02-practice-lab", outputDir: outputDir)

        openLabelingFromPractice()
        capture(name: "03-anatomy-labeling", outputDir: outputDir)
        navigateBackFromLabeling()

        tapTab("Collection")
        XCTAssertTrue(app.navigationBars["Collection"].waitForExistence(timeout: 5))
        capture(name: "04-collection-gallery", outputDir: outputDir)

        tapTab("Progress")
        XCTAssertTrue(app.staticTexts["XP Earned"].waitForExistence(timeout: 5))
        capture(name: "05-progress-dashboard", outputDir: outputDir)

        tapTab("Sessions")
        XCTAssertTrue(app.staticTexts["Available Tutors"].waitForExistence(timeout: 5))
        capture(name: "06-tutor-sessions", outputDir: outputDir)
    }

    @MainActor
    private func openLabelingFromPractice() {
        tapTab("Practice")
        let labelingLink = app.buttons["practice-labeling-link"].firstMatch
        if labelingLink.waitForExistence(timeout: 5), labelingLink.isHittable {
            labelingLink.tap()
        } else {
            tapLabelingCardByCoordinate()
        }

        XCTAssertTrue(waitForLabelingScreen(timeout: 5), "Labeling screen did not open")
    }

    @MainActor
    private func tapLabelingCardByCoordinate() {
        let labelingText = app.staticTexts["Labeling"]
        XCTAssertTrue(labelingText.waitForExistence(timeout: 5))
        let frame = labelingText.frame
        let coordinate = app.coordinate(withNormalizedOffset: .zero).withOffset(
            CGVector(dx: frame.midX, dy: frame.midY)
        )
        coordinate.tap()
    }

    @MainActor
    private func waitForLabelingScreen(timeout: TimeInterval) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        let instruction = app.staticTexts["Select a label, then tap its region"]
        let partialInstruction = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[c] %@", "tap its region")
        ).firstMatch
        let scoreText = app.staticTexts["0/6"]

        while Date() < deadline {
            if app.navigationBars["Labeling"].exists || instruction.exists || partialInstruction.exists || scoreText.exists {
                return true
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.2))
        }

        return false
    }

    @MainActor
    private func navigateBackFromLabeling() {
        let navBackButton = app.navigationBars.buttons.element(boundBy: 0)
        if navBackButton.waitForExistence(timeout: 2) {
            navBackButton.tap()
            return
        }

        let practiceTab = app.buttons["Practice"].firstMatch
        if practiceTab.waitForExistence(timeout: 2) {
            practiceTab.tap()
        }
    }

    @MainActor
    private func tapTab(_ name: String) {
        if tapTopTabStrip(name) { return }

        // iOS 26+: tab bar uses a different accessibility container — broad button search.
        let labelPred = NSPredicate(format: "label == %@", name)
        let anyButton = app.buttons.matching(labelPred).firstMatch
        if anyButton.waitForExistence(timeout: 8) {
            anyButton.tap()
            return
        }

        // Legacy iOS tab bar fallback.
        let tabBar = app.tabBars.firstMatch
        if tabBar.waitForExistence(timeout: 3) {
            let directTab = tabBar.buttons[name]
            if directTab.waitForExistence(timeout: 3), directTab.isHittable {
                directTab.tap()
                return
            }
            let more = tabBar.buttons["More"]
            if more.waitForExistence(timeout: 2) {
                more.tap()
                for item in [app.buttons[name], app.staticTexts[name],
                             app.cells[name],
                             app.cells.containing(NSPredicate(format: "label CONTAINS[c] %@", name)).firstMatch] {
                    if item.waitForExistence(timeout: 2) { item.tap(); return }
                }
            }
        }

        XCTFail("Tab '\(name)' not found in tab bar or More menu")
    }

    @MainActor
    private func tapTopTabStrip(_ name: String) -> Bool {
        let window = app.windows.firstMatch
        guard window.waitForExistence(timeout: 1), window.frame.width > 700 else {
            return false
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
            return false
        }

        window.coordinate(withNormalizedOffset: CGVector(dx: x, dy: 0.04)).tap()
        return true
    }

    private static func resolveOutputDirectory() -> String {
        if let env = ProcessInfo.processInfo.environment["DISTRIBUTION_OUTPUT_DIR"],
           !env.isEmpty {
            return env
        }
        return defaultOutputDirectory
    }

    private func capture(name: String, outputDir: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let path = (outputDir as NSString).appendingPathComponent("\(name).png")
        do {
            try screenshot.pngRepresentation.write(to: URL(fileURLWithPath: path))
            let attachment = XCTAttachment(screenshot: screenshot)
            attachment.name = name
            attachment.lifetime = .keepAlways
            add(attachment)
        } catch {
            XCTFail("Failed to write screenshot \(name): \(error)")
        }
    }
}
