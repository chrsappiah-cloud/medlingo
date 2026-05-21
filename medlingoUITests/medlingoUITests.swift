import XCTest

final class medlingoUITests: XCTestCase {

    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["-UITesting"]
        app.launch()
    }

    // MARK: - Tab Navigation Helpers

    /// Taps a tab by name, opening the More menu when tabs overflow on compact devices.
    @MainActor
    private func tapTab(_ name: String, file: StaticString = #file, line: UInt = #line) {
        let tabBar = app.tabBars.firstMatch
        let directTab = tabBar.buttons[name]

        if directTab.waitForExistence(timeout: 2), directTab.isHittable {
            directTab.tap()
            return
        }

        let more = tabBar.buttons["More"]
        XCTAssertTrue(more.waitForExistence(timeout: 3), "Tab '\(name)' not found in tab bar or More", file: file, line: line)
        more.tap()

        let overflowButton = app.buttons[name]
        if overflowButton.waitForExistence(timeout: 3) {
            overflowButton.tap()
            return
        }

        let overflowCell = app.cells.containing(NSPredicate(format: "label CONTAINS[c] %@", name)).firstMatch
        XCTAssertTrue(overflowCell.waitForExistence(timeout: 3), "Tab '\(name)' not found in More menu", file: file, line: line)
        overflowCell.tap()
    }

    @MainActor
    private func tabIsReachable(_ name: String) -> Bool {
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

    // MARK: - Tab Bar Tests

    @MainActor
    func testTabBarExists() throws {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.exists)
    }

    @MainActor
    func testAllTabsPresent() throws {
        let tabBar = app.tabBars.firstMatch
        for name in ["Learn", "Practice", "Collection", "Sessions"] {
            XCTAssertTrue(tabBar.buttons[name].exists, "\(name) should appear in the tab bar")
        }
        XCTAssertTrue(tabIsReachable("Progress"))
        XCTAssertTrue(tabIsReachable("Account"))
        XCTAssertFalse(tabIsReachable("Studio"), "Studio tab should be hidden for learner role")
    }

    @MainActor
    func testTabNavigation() throws {
        tapTab("Practice")
        XCTAssertTrue(app.navigationBars["Practice Lab"].waitForExistence(timeout: 3))

        tapTab("Sessions")
        XCTAssertTrue(app.navigationBars["Sessions"].waitForExistence(timeout: 3))

        tapTab("Progress")
        XCTAssertTrue(app.navigationBars["Progress"].waitForExistence(timeout: 3))

        tapTab("Account")
        XCTAssertTrue(app.navigationBars["Account"].waitForExistence(timeout: 3))

        tapTab("Learn")
        XCTAssertTrue(app.staticTexts["Medlingo"].waitForExistence(timeout: 3))
    }

    // MARK: - Home Screen Tests

    @MainActor
    func testHomeScreenContent() throws {
        XCTAssertTrue(app.staticTexts["Medlingo"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Continue Learning"].exists)
        XCTAssertTrue(app.staticTexts["Stages"].exists)
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
        tapTab("Practice")
        XCTAssertTrue(app.staticTexts["Daily Goal"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Practice Modes"].exists)
        XCTAssertTrue(app.staticTexts["Flashcards"].exists)
        XCTAssertTrue(app.staticTexts["Word Builder"].exists)
        XCTAssertTrue(app.staticTexts["Quiz"].exists)
    }

    @MainActor
    func testPracticeLabWeakAreas() throws {
        tapTab("Practice")
        let weakAreas = app.staticTexts["Weak Areas"]
        XCTAssertTrue(weakAreas.waitForExistence(timeout: 3))
    }

    // MARK: - Sessions Tab Tests

    @MainActor
    func testSessionsScreenContent() throws {
        tapTab("Sessions")
        XCTAssertTrue(app.staticTexts["Next Session"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Available Tutors"].exists)
    }

    @MainActor
    func testTutorCardsVisible() throws {
        tapTab("Sessions")
        let tutorName = app.staticTexts["Dr. Sarah Mitchell"]
        XCTAssertTrue(tutorName.waitForExistence(timeout: 3))
    }

    // MARK: - Progress Tab Tests

    @MainActor
    func testProgressDashboardContent() throws {
        tapTab("Progress")
        XCTAssertTrue(app.staticTexts["XP Earned"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Stages"].exists)
        XCTAssertTrue(app.staticTexts["Mastery"].exists)
    }

    @MainActor
    func testProgressStreakSection() throws {
        tapTab("Progress")
        let streak = app.staticTexts["7 Day Streak!"]
        XCTAssertTrue(streak.waitForExistence(timeout: 3))
    }

    @MainActor
    func testProgressChapterList() throws {
        tapTab("Progress")
        XCTAssertTrue(app.staticTexts["Stage Progress"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Word Parts & Foundations"].exists)
    }

    // MARK: - Collection Tab Tests

    @MainActor
    func testCollectionTabContent() throws {
        tapTab("Collection")
        XCTAssertTrue(app.navigationBars["Collection"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Artworks"].waitForExistence(timeout: 3))
    }

    // MARK: - Account Tab Tests

    @MainActor
    func testAccountScreenContent() throws {
        tapTab("Account")
        XCTAssertTrue(app.staticTexts["Christopher"].waitForExistence(timeout: 3))
    }

    @MainActor
    func testAccountSubscriptionLink() throws {
        tapTab("Account")
        let premiumPlan = app.staticTexts["Premium Plan"]
        XCTAssertTrue(premiumPlan.waitForExistence(timeout: 3))
    }

    @MainActor
    func testAccountSignOutButton() throws {
        tapTab("Account")
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
        tapTab("Practice")
        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.waitForExistence(timeout: 3))
        scrollView.swipeUp()
    }

    // MARK: - Labeling View Tests

    @MainActor
    func testLabelingViewOpensFromPracticeLab() throws {
        tapTab("Practice")

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
        tapTab("Practice")

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
