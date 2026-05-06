import XCTest

final class medlingoUITests: XCTestCase {

    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    // MARK: - Tab Bar Tests

    @MainActor
    func testTabBarExists() throws {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.exists)
    }

    @MainActor
    func testAllTabsPresent() throws {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.buttons["Learn"].exists)
        XCTAssertTrue(tabBar.buttons["Practice"].exists)
        XCTAssertTrue(tabBar.buttons["Sessions"].exists)
        XCTAssertTrue(tabBar.buttons["Progress"].exists)
        XCTAssertTrue(tabBar.buttons["Account"].exists)
    }

    @MainActor
    func testTabNavigation() throws {
        let tabBar = app.tabBars.firstMatch

        tabBar.buttons["Practice"].tap()
        XCTAssertTrue(app.navigationBars["Practice Lab"].waitForExistence(timeout: 3))

        tabBar.buttons["Sessions"].tap()
        XCTAssertTrue(app.navigationBars["Sessions"].waitForExistence(timeout: 3))

        tabBar.buttons["Progress"].tap()
        XCTAssertTrue(app.navigationBars["Progress"].waitForExistence(timeout: 3))

        tabBar.buttons["Account"].tap()
        XCTAssertTrue(app.navigationBars["Account"].waitForExistence(timeout: 3))

        tabBar.buttons["Learn"].tap()
        XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: 3))
    }

    // MARK: - Home Screen Tests

    @MainActor
    func testHomeScreenContent() throws {
        XCTAssertTrue(app.staticTexts["Welcome back!"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Continue Learning"].exists)
        XCTAssertTrue(app.staticTexts["Chapters"].exists)
    }

    @MainActor
    func testHomeScreenStreakVisible() throws {
        let streakText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'streak'")).firstMatch
        XCTAssertTrue(streakText.waitForExistence(timeout: 3))
    }

    @MainActor
    func testHomeScreenResumeButton() throws {
        let resumeButton = app.buttons["Resume"]
        XCTAssertTrue(resumeButton.waitForExistence(timeout: 3))
    }

    @MainActor
    func testResumeButtonNavigatesToStageDetail() throws {
        let resumeButton = app.buttons["Resume"]
        XCTAssertTrue(resumeButton.waitForExistence(timeout: 3))
        resumeButton.tap()

        let stageTitle = app.navigationBars["Stage 3"]
        XCTAssertTrue(stageTitle.waitForExistence(timeout: 5), "Tapping Resume should navigate to Stage 3 detail")

        let lessonsHeader = app.staticTexts["Lessons"]
        XCTAssertTrue(lessonsHeader.waitForExistence(timeout: 3), "Stage detail should show Lessons section")

        let practiceHeader = app.staticTexts["Practice"]
        XCTAssertTrue(practiceHeader.exists, "Stage detail should show Practice section")
    }

    @MainActor
    func testStageBadgeNavigatesToStageDetail() throws {
        let foundationsBadge = app.staticTexts["Foundations"]
        XCTAssertTrue(foundationsBadge.waitForExistence(timeout: 3))
        foundationsBadge.tap()

        let stageTitle = app.navigationBars["Stage 1"]
        XCTAssertTrue(stageTitle.waitForExistence(timeout: 5), "Tapping stage badge should navigate to Stage detail")

        let flashcardsText = app.staticTexts["Flashcards"]
        XCTAssertTrue(flashcardsText.waitForExistence(timeout: 3), "Stage detail should show Flashcards practice card")
    }

    // MARK: - Practice Lab Tests

    @MainActor
    func testPracticeLabContent() throws {
        app.tabBars.firstMatch.buttons["Practice"].tap()
        XCTAssertTrue(app.staticTexts["Daily Goal"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Practice Modes"].exists)
        XCTAssertTrue(app.staticTexts["Flashcards"].exists)
        XCTAssertTrue(app.staticTexts["Word Builder"].exists)
        XCTAssertTrue(app.staticTexts["Quiz"].exists)
    }

    @MainActor
    func testPracticeLabWeakAreas() throws {
        app.tabBars.firstMatch.buttons["Practice"].tap()
        let weakAreas = app.staticTexts["Weak Areas"]
        XCTAssertTrue(weakAreas.waitForExistence(timeout: 3))
    }

    // MARK: - Sessions Tab Tests

    @MainActor
    func testSessionsScreenContent() throws {
        app.tabBars.firstMatch.buttons["Sessions"].tap()
        XCTAssertTrue(app.staticTexts["Next Session"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Available Tutors"].exists)
    }

    @MainActor
    func testTutorCardsVisible() throws {
        app.tabBars.firstMatch.buttons["Sessions"].tap()
        let tutorName = app.staticTexts["Dr. Sarah Mitchell"]
        XCTAssertTrue(tutorName.waitForExistence(timeout: 3))
    }

    // MARK: - Progress Tab Tests

    @MainActor
    func testProgressDashboardContent() throws {
        app.tabBars.firstMatch.buttons["Progress"].tap()
        XCTAssertTrue(app.staticTexts["XP Earned"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Chapters"].exists)
        XCTAssertTrue(app.staticTexts["Mastery"].exists)
    }

    @MainActor
    func testProgressStreakSection() throws {
        app.tabBars.firstMatch.buttons["Progress"].tap()
        let streak = app.staticTexts["7 Day Streak!"]
        XCTAssertTrue(streak.waitForExistence(timeout: 3))
    }

    @MainActor
    func testProgressChapterList() throws {
        app.tabBars.firstMatch.buttons["Progress"].tap()
        XCTAssertTrue(app.staticTexts["Chapter Progress"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Word Parts & Foundations"].exists)
    }

    // MARK: - Account Tab Tests

    @MainActor
    func testAccountScreenContent() throws {
        app.tabBars.firstMatch.buttons["Account"].tap()
        XCTAssertTrue(app.staticTexts["Christopher"].waitForExistence(timeout: 3))
    }

    @MainActor
    func testAccountSubscriptionLink() throws {
        app.tabBars.firstMatch.buttons["Account"].tap()
        let premiumPlan = app.staticTexts["Premium Plan"]
        XCTAssertTrue(premiumPlan.waitForExistence(timeout: 3))
    }

    @MainActor
    func testAccountSignOutButton() throws {
        app.tabBars.firstMatch.buttons["Account"].tap()
        let list = app.collectionViews.firstMatch
        list.swipeUp()
        let signOut = app.buttons["Sign Out"]
        XCTAssertTrue(signOut.waitForExistence(timeout: 5))
    }

    // MARK: - Scrolling & Interaction Tests

    @MainActor
    func testHomeScreenScrollable() throws {
        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.exists)
        scrollView.swipeUp()
    }

    @MainActor
    func testPracticeLabScrollable() throws {
        app.tabBars.firstMatch.buttons["Practice"].tap()
        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.waitForExistence(timeout: 3))
        scrollView.swipeUp()
    }

    // MARK: - Labeling View Tests

    @MainActor
    func testLabelingViewOpensFromPracticeLab() throws {
        app.tabBars.firstMatch.buttons["Practice"].tap()

        let labelingText = app.staticTexts["Labeling"]
        XCTAssertTrue(labelingText.waitForExistence(timeout: 5))

        let container = labelingText.firstMatch
        container.tap()

        let navTitle = app.navigationBars["Labeling"]
        if !navTitle.waitForExistence(timeout: 5) {
            app.staticTexts["Anatomy ID"].tap()
            XCTAssertTrue(navTitle.waitForExistence(timeout: 5), "Should navigate to Labeling view")
        }
    }

    @MainActor
    func testLabelingViewShowsLabelsAndInteracts() throws {
        app.tabBars.firstMatch.buttons["Practice"].tap()

        let labelingText = app.staticTexts["Labeling"]
        XCTAssertTrue(labelingText.waitForExistence(timeout: 5))
        labelingText.tap()

        if !app.navigationBars["Labeling"].waitForExistence(timeout: 3) {
            app.staticTexts["Anatomy ID"].tap()
        }

        let labelsHeader = app.staticTexts["LABELS"]
        if labelsHeader.waitForExistence(timeout: 5) {
            let craniumButton = app.buttons["Cranium"]
            if craniumButton.waitForExistence(timeout: 3) {
                craniumButton.tap()
                let hintButton = app.buttons["Hint"]
                XCTAssertTrue(hintButton.waitForExistence(timeout: 3), "Hint button should appear after selecting a label")
            }
        }
    }
}
