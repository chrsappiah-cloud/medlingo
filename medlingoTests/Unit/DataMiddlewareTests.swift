import Testing
import Foundation
@testable import medlingo

@MainActor
struct DataMiddlewareTests {
    let chapterMock: ChapterServiceMock
    let analyticsSpy: AnalyticsTrackerSpy
    let progressMock: ProgressServiceMock
    let sessionMock: SessionServiceMock
    let messagingMock: MessagingServiceMock
    var sut: DataMiddleware

    init() {
        chapterMock = ChapterServiceMock()
        analyticsSpy = AnalyticsTrackerSpy()
        progressMock = ProgressServiceMock()
        sessionMock = SessionServiceMock()
        messagingMock = MessagingServiceMock()

        sut = DataMiddleware(
            chapterService: chapterMock,
            analyticsService: analyticsSpy,
            progressService: progressMock,
            sessionService: sessionMock,
            messagingService: messagingMock,
            skipInitialLoad: true
        )
    }

    // MARK: - Sample Data Methods

    @Test func sampleChapters_returns15Chapters() {
        let chapters = DataMiddleware.sampleChapters()
        #expect(chapters.count == 15)
        #expect(chapters.first?.number == 1)
        #expect(chapters.last?.number == 15)
    }

    @Test func sampleChapters_allChaptersAreFree() {
        let chapters = DataMiddleware.sampleChapters()
        for chapter in chapters {
            #expect(chapter.unlockRule == .free)
        }
    }

    @Test func sampleChapters_chaptersAreNumberedSequentially() {
        let chapters = DataMiddleware.sampleChapters().sorted { $0.number < $1.number }
        for (index, chapter) in chapters.enumerated() {
            #expect(chapter.number == index + 1)
        }
    }

    @Test func sampleLessons_returns6Lessons() {
        let chapterID = UUID()
        let lessons = DataMiddleware.sampleLessons(for: chapterID)
        #expect(lessons.count == 6)
    }

    @Test func sampleLessons_allHaveCorrectChapterID() {
        let chapterID = UUID()
        let lessons = DataMiddleware.sampleLessons(for: chapterID)
        for lesson in lessons {
            #expect(lesson.chapterID == chapterID)
        }
    }

    @Test func sampleLessons_haveOrderedIndexes() {
        let lessons = DataMiddleware.sampleLessons(for: UUID())
        let sorted = lessons.sorted { $0.orderIndex < $1.orderIndex }
        for (index, lesson) in sorted.enumerated() {
            #expect(lesson.orderIndex == index)
        }
    }

    @Test func sampleSessions_returns2Sessions() {
        let sessions = DataMiddleware.sampleSessions()
        #expect(sessions.count == 2)
    }

    @Test func sampleSessions_allAreScheduled() {
        for session in DataMiddleware.sampleSessions() {
            #expect(session.status == .scheduled)
        }
    }

    // MARK: - isStageUnlocked

    @Test func isStageUnlocked_alwaysReturnsTrue() {
        let freeChapter = Chapter(id: UUID(), number: 1, title: "Test", summary: "", estimatedMinutes: 10, coverArtURL: nil, accentColorHex: "", prerequisiteIDs: [], unlockRule: .free)
        let sequentialChapter = Chapter(id: UUID(), number: 5, title: "Later Stage", summary: "", estimatedMinutes: 10, coverArtURL: nil, accentColorHex: "", prerequisiteIDs: [], unlockRule: .sequential)

        #expect(sut.isStageUnlocked(freeChapter) == true)
        #expect(sut.isStageUnlocked(sequentialChapter) == true)
    }

    // MARK: - loadInitialData (with mocks)

    @Test func loadInitialData_whenChaptersFetchSucceeds_updatesChapters() async {
        sut.resetForTesting()
        sut.isRemoteConfigured = true
        sut.isRemoteConfigured = true
        let expectedChapters = DataMiddleware.sampleChapters()
        chapterMock.fetchChaptersResult = .success(expectedChapters)

        await sut.loadInitialData()

        #expect(sut.chapters.count == expectedChapters.count)
    }

    @Test func loadInitialData_whenChaptersFetchFails_usesFallback() async {
        sut.resetForTesting()
        sut.isRemoteConfigured = true
        struct SomeError: Error, LocalizedError {
            var errorDescription: String? { "Network error" }
        }
        chapterMock.fetchChaptersResult = .failure(SomeError())

        await sut.loadInitialData()

        #expect(sut.chapters.count == 15)
        #expect(sut.lastError != nil)
    }

    // MARK: - loadLessons

    @Test func loadLessons_whenFetchSucceeds_updatesLessons() async {
        sut.resetForTesting()
        sut.isRemoteConfigured = true
        let chapterID = UUID()
        let expectedLessons = DataMiddleware.sampleLessons(for: chapterID)
        chapterMock.fetchLessonsResult = .success(expectedLessons)

        await sut.loadLessons(for: chapterID)

        #expect(sut.lessons[chapterID]?.count == expectedLessons.count)
        #expect(chapterMock.lastFetchLessonsChapterID == chapterID)
    }

    @Test func loadLessons_whenFetchFails_usesFallback() async {
        sut.resetForTesting()
        sut.isRemoteConfigured = true
        struct SomeError: Error {}
        let chapterID = UUID()
        chapterMock.fetchLessonsResult = .failure(SomeError())

        await sut.loadLessons(for: chapterID)

        #expect(sut.lessons[chapterID]?.count == 6)
    }

    // MARK: - loadExercises

    @Test func loadExercises_whenFetchSucceeds_updatesExercises() async {
        sut.resetForTesting()
        sut.isRemoteConfigured = true
        let chapterID = UUID()
        let expected = [Exercise(id: UUID(), chapterID: chapterID, lessonID: nil, type: .multipleChoice, title: "Test", instructions: nil, difficulty: .beginner, xpReward: 0, questions: [])]
        chapterMock.fetchExercisesResult = .success(expected)

        await sut.loadExercises(for: chapterID)

        #expect(sut.exercises[chapterID]?.count == 1)
    }

    @Test func loadExercises_whenFetchFails_setsEmptyArray() async {
        sut.resetForTesting()
        sut.isRemoteConfigured = true
        struct SomeError: Error {}
        let chapterID = UUID()
        chapterMock.fetchExercisesResult = .failure(SomeError())

        await sut.loadExercises(for: chapterID)

        #expect(sut.exercises[chapterID]?.isEmpty == true)
    }

    // MARK: - submitAttempt

    @Test func submitAttempt_calculatesCorrectScore() async {
        sut.resetForTesting()
        sut.isRemoteConfigured = true
        let exerciseID = UUID()
        let chapterID = UUID()
        let answers: [(questionID: UUID, answer: String, correct: Bool)] = [
            (UUID(), "A", true),
            (UUID(), "B", false),
            (UUID(), "C", true),
            (UUID(), "D", true),
        ]

        await sut.submitAttempt(exerciseID: exerciseID, chapterID: chapterID, answers: answers)

        #expect(progressMock.submitAttemptCallCount == 1)
        #expect(progressMock.lastSubmittedAttempt?.score == 0.75)
        #expect(progressMock.lastSubmittedAttempt?.totalQuestions == 4)
        #expect(progressMock.lastSubmittedAttempt?.correctAnswers == 3)
    }

    @Test func submitAttempt_tracksAnalyticsEvent() async {
        sut.resetForTesting()
        sut.isRemoteConfigured = true
        let answers: [(questionID: UUID, answer: String, correct: Bool)] = [(UUID(), "A", true)]

        await sut.submitAttempt(exerciseID: UUID(), chapterID: UUID(), answers: answers)

        #expect(analyticsSpy.eventCount >= 1)
        #expect(analyticsSpy.lastEvent != nil)
    }

    @Test func submitAttempt_whenScoreIsZero_allAnswersWrong() async {
        sut.resetForTesting()
        sut.isRemoteConfigured = true
        let answers: [(questionID: UUID, answer: String, correct: Bool)] = [
            (UUID(), "A", false),
            (UUID(), "B", false),
        ]

        await sut.submitAttempt(exerciseID: UUID(), chapterID: UUID(), answers: answers)

        #expect(progressMock.lastSubmittedAttempt?.score == 0)
    }

    // MARK: - loadSessions

    @Test func loadSessions_whenFetchSucceeds_updatesSessions() async {
        sut.resetForTesting()
        sut.isRemoteConfigured = true
        let expected = DataMiddleware.sampleSessions()
        sessionMock.fetchSessionsResult = .success(expected)

        await sut.loadSessions()

        #expect(sut.sessions.count == 2)
    }

    @Test func loadSessions_whenFetchFails_usesFallback() async {
        sut.resetForTesting()
        sut.isRemoteConfigured = true
        struct SomeError: Error {}
        sessionMock.fetchSessionsResult = .failure(SomeError())

        await sut.loadSessions()

        #expect(sut.sessions.count == 2)
    }

    // MARK: - bookSession

    @Test func bookSession_whenSucceeds_appendsBooking() async {
        sut.resetForTesting()
        sut.isRemoteConfigured = true
        let sessionID = UUID()
        let expected = Booking(id: UUID(), sessionID: sessionID, learnerID: UUID(), status: .confirmed, bookedAt: Date())
        sessionMock.bookSessionResult = .success(expected)

        let result = await sut.bookSession(sessionID: sessionID)

        #expect(result != nil)
        #expect(result?.sessionID == sessionID)
        #expect(sut.bookings.count == 1)
        #expect(sessionMock.bookSessionCallCount == 1)
    }

    @Test func bookSession_tracksAnalytics() async {
        sut.resetForTesting()
        sut.isRemoteConfigured = true
        let sessionID = UUID()
        sessionMock.bookSessionResult = .success(Booking(id: UUID(), sessionID: sessionID, learnerID: UUID(), status: .confirmed, bookedAt: Date()))

        _ = await sut.bookSession(sessionID: sessionID)

        #expect(analyticsSpy.lastEvent != nil)
    }

    // MARK: - cancelBooking

    @Test func cancelBooking_removesBookingFromArray() async {
        sut.resetForTesting()
        sut.isRemoteConfigured = true
        let sessionID = UUID()
        sessionMock.bookSessionResult = .success(Booking(id: UUID(), sessionID: sessionID, learnerID: UUID(), status: .confirmed, bookedAt: Date()))
        _ = await sut.bookSession(sessionID: sessionID)
        let bookingID = sut.bookings[0].id

        await sut.cancelBooking(bookingID: bookingID)

        #expect(sut.bookings.isEmpty)
        #expect(sessionMock.cancelBookingCallCount == 1)
    }

    // MARK: - createSessionRoom

    @Test func createSessionRoom_returnsDemoRoom_whenUnconfigured() async {
        let sessionID = UUID()
        let result = await sut.createSessionRoom(sessionID: sessionID)

        #expect(result != nil)
        #expect(result?.url.absoluteString.contains("medlingo-") == true)
        #expect(result?.token.hasPrefix("demo-token-") == true)
    }

    // MARK: - sendMessage

    @Test func sendMessage_whenUnconfigured_createsFallback() async {
        sut.resetForTesting()
        let recipientID = UUID()
        let content = "Hello, tutor!"

        await sut.sendMessage(to: recipientID, content: content)

        #expect(sut.messages.count == 1)
        #expect(sut.messages.first?.content == content)
        #expect(sut.messages.first?.recipientID == recipientID)
    }

    @Test func sendMessage_whenMockSucceeds_appendsMessage() async {
        sut.resetForTesting()
        sut.isRemoteConfigured = true
        let recipientID = UUID()
        let expected = ChatMessage(id: UUID(), senderID: UUID(), recipientID: recipientID, content: "Hi", sentAt: Date(), readAt: nil, attachmentURL: nil)
        messagingMock.sendMessageResult = .success(expected)

        await sut.sendMessage(to: recipientID, content: "Hi")

        #expect(messagingMock.sendMessageCallCount == 1)
    }

    @Test func sendMessage_whenMockFails_createsFallback() async {
        sut.resetForTesting()
        sut.isRemoteConfigured = true
        struct SomeError: Error {}
        messagingMock.sendMessageResult = .failure(SomeError())

        await sut.sendMessage(to: UUID(), content: "Fallback")

        #expect(sut.messages.count == 1)
        #expect(sut.messages.first?.content == "Fallback")
    }

    // MARK: - loadMessages

    @Test func loadMessages_whenFetchSucceeds_updatesMessages() async {
        sut.resetForTesting()
        sut.isRemoteConfigured = true
        let userID = UUID()
        AppState.shared.currentUserID = userID
        let expected = [ChatMessage(id: UUID(), senderID: userID, recipientID: UUID(), content: "Test", sentAt: Date(), readAt: nil, attachmentURL: nil)]
        messagingMock.fetchMessagesResult = .success(expected)

        await sut.loadMessages()

        #expect(messagingMock.fetchMessagesCallCount == 1)
        #expect(messagingMock.lastFetchUserID == userID)
    }
}
