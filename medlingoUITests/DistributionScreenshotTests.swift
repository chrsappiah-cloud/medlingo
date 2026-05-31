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
        app.navigationBars.buttons.element(boundBy: 0).tap()

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
        let labelingText = app.staticTexts["Labeling"]
        XCTAssertTrue(labelingText.waitForExistence(timeout: 5))
        labelingText.tap()

        if !app.navigationBars["Labeling"].waitForExistence(timeout: 3) {
            app.staticTexts["Anatomy ID"].tap()
            XCTAssertTrue(app.navigationBars["Labeling"].waitForExistence(timeout: 5))
        }
    }

    @MainActor
    private func tapTab(_ name: String) {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))

        let directTab = tabBar.buttons[name]
        if directTab.waitForExistence(timeout: 5) {
            if directTab.isHittable {
                directTab.tap()
                return
            }
            tabBar.swipeLeft()
            if directTab.isHittable {
                directTab.tap()
                return
            }
            tabBar.swipeRight()
            tabBar.swipeRight()
            if directTab.isHittable {
                directTab.tap()
                return
            }
            directTab.tap()
            return
        }

        let more = tabBar.buttons["More"]
        if more.waitForExistence(timeout: 2) {
            more.tap()
            let menuItems = [
                app.buttons[name],
                app.staticTexts[name],
                app.cells[name],
                app.cells.containing(NSPredicate(format: "label CONTAINS[c] %@", name)).firstMatch,
            ]
            for item in menuItems {
                if item.waitForExistence(timeout: 2) {
                    item.tap()
                    return
                }
            }
        }

        XCTFail("Tab '\(name)' not found in tab bar or More menu")
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
