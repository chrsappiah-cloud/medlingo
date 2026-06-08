import XCTest

final class medlingoUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        false
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launchArguments = UITestLaunchArguments.standardSmoke()
        app.launch()

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    @MainActor
    func testLaunchPerformance() throws {
        #if !targetEnvironment(simulator)
        throw XCTSkip("Launch performance baselines are measured on simulator only")
        #else
        // Top-tier iOS apps target <2.5s cold launch on simulator (99th percentile).
        let app = XCUIApplication()
        app.launchArguments = UITestLaunchArguments.standardSmoke()

        let options = XCTMeasureOptions()
        options.iterationCount = 5
        options.invocationOptions = [.manuallyStop]

        measure(metrics: [XCTApplicationLaunchMetric()], options: options) {
            app.terminate()
            app.launch()
            stopMeasuring()
        }
        #endif
    }
}
