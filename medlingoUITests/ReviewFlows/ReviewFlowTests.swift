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
    func testAccount_cleanLaunchShowsGuestAndNoSignOut() throws {
        launchApp()
        tapTab("Account")
        XCTAssertTrue(app.staticTexts["Guest learner"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["No account signed in"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["sign-out-button"].exists)
    }


    @MainActor
    func testAccount_appReviewCredentialsSignInWithoutError() throws {
        launchApp()
        tapTab("Account")
        XCTAssertTrue(app.staticTexts["Guest learner"].waitForExistence(timeout: 5))

        let signIn = app.buttons["sign-in-button"]
        if !signIn.waitForExistence(timeout: 3) { app.collectionViews.firstMatch.swipeUp() }
        XCTAssertTrue(signIn.waitForExistence(timeout: 8))
        signIn.tap()

        let emailField = app.textFields["sign-in-email-field"]
        XCTAssertTrue(emailField.waitForExistence(timeout: 5))
        emailField.tap()
        emailField.typeText("reviewer@medlingo.app")

        let passwordField = app.secureTextFields["sign-in-password-field"]
        XCTAssertTrue(passwordField.waitForExistence(timeout: 5))
        passwordField.tap()
        passwordField.typeText("Review2026!")

        let submit = app.buttons["sign-in-submit-button"].firstMatch
        XCTAssertTrue(submit.waitForExistence(timeout: 5))
        submit.tap()
        XCTAssertTrue(app.staticTexts["Review Learner"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["sign-in-error-label"].exists)
    }

    @MainActor
    func testAccount_signOutClearsAuthenticatedSession() throws {
        launchApp(arguments: [
            UITestLaunchArguments.uiTestMode,
            UITestLaunchArguments.seedAuthenticatedSession
        ])
        tapTab("Account")
        XCTAssertTrue(app.staticTexts["Review Learner"].waitForExistence(timeout: 5))
        let signOut = app.buttons["sign-out-button"]
        if !signOut.waitForExistence(timeout: 3) { app.collectionViews.firstMatch.swipeUp() }
        XCTAssertTrue(signOut.waitForExistence(timeout: 8))
        signOut.tap()
        XCTAssertTrue(app.alerts["Account"].waitForExistence(timeout: 5))
        app.alerts["Account"].buttons["OK"].tap()
        XCTAssertTrue(app.staticTexts["Guest learner"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["sign-out-button"].exists)
    }
}
