import XCTest

final class AIVideoGenerationTests: UITestCaseBase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        addUIInterruptionMonitor(withDescription: "System alerts") { alert in
            if alert.buttons["Allow"].exists { alert.buttons["Allow"].tap(); return true }
            if alert.buttons["OK"].exists { alert.buttons["OK"].tap(); return true }
            return false
        }
    }

    @MainActor
    func testGenerationStudio_videoGeneration_completesWithResult() throws {
        launchApp(arguments: UITestLaunchArguments.aiVideoGeneration())

        tapTab("Studio")
        XCTAssertTrue(app.navigationBars["Generation Studio"].waitForExistence(timeout: 8))

        app.buttons["Video"].tap()

        let generate = app.buttons["generate-artwork-button"]
        if !generate.waitForExistence(timeout: 8) {
            for _ in 0..<6 { app.swipeUp() }
        }
        XCTAssertTrue(generate.waitForExistence(timeout: 8))
        generate.tap()

        let completeNav = app.navigationBars["Generation Complete"]
        let success = app.staticTexts["generation-result-success"]
        XCTAssertTrue(
            completeNav.waitForExistence(timeout: 50) || success.waitForExistence(timeout: 5),
            "AI video demo generation should complete on device"
        )
    }
}
