import XCTest

/// Captures the Premium subscription paywall for App Store IAP review screenshots.
final class IAPReviewScreenshotTests: XCTestCase {
  private let app = XCUIApplication()

  override func setUpWithError() throws {
    continueAfterFailure = false
    app.launchArguments = ["-UITesting", "-subscriptionReviewScreenshot"]
    app.launch()
  }

  @MainActor
  func testCaptureIAPReviewScreenshot() throws {
    let outputDir = Self.resolveOutputDirectory()
    try FileManager.default.createDirectory(atPath: outputDir, withIntermediateDirectories: true)

    XCTAssertTrue(app.navigationBars["Subscription"].waitForExistence(timeout: 10))
    XCTAssertTrue(app.staticTexts["Available Plans"].waitForExistence(timeout: 10))

    let screenshot = XCUIScreen.main.screenshot()
    let path = (outputDir as NSString).appendingPathComponent("premium-paywall.png")
    try screenshot.pngRepresentation.write(to: URL(fileURLWithPath: path))

    let attachment = XCTAttachment(screenshot: screenshot)
    attachment.name = "iap-premium-paywall"
    attachment.lifetime = .keepAlways
    add(attachment)
  }

  private static func resolveOutputDirectory() -> String {
    if let env = ProcessInfo.processInfo.environment["DISTRIBUTION_IAP_OUTPUT_DIR"], !env.isEmpty {
      return env
    }
    return "/tmp/medlingo-iap-screenshots"
  }
}
