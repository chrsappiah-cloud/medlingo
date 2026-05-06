import Foundation

@MainActor
@Observable
final class DataMiddleware {
    static let shared = DataMiddleware()

    private(set) var chapters: [Chapter] = []
    private(set) var lessons: [UUID: [Lesson]] = [:]
    private(set) var exercises: [UUID: [Exercise]] = [:]
    private(set) var progress: [UUID: Double] = [:]
    private(set) var entitlements: [Entitlement] = []
    private(set) var sessions: [TutorSession] = []
    private(set) var bookings: [Booking] = []
    private(set) var messages: [ChatMessage] = []

    private(set) var isLoading = false
    private(set) var lastError: String?

    private let chapterService: ChapterServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol

    private init(
        chapterService: ChapterServiceProtocol = ChapterService(),
        analyticsService: AnalyticsServiceProtocol = AnalyticsService.shared
    ) {
        self.chapterService = chapterService
        self.analyticsService = analyticsService
        Task { await loadInitialData() }
    }

    func loadInitialData() async {
        isLoading = true
        defer { isLoading = false }

        do {
            chapters = try await chapterService.fetchChapters()
        } catch {
            chapters = Self.sampleChapters()
            lastError = error.localizedDescription
        }
    }

    func loadLessons(for chapterID: UUID) async {
        do {
            let chapterLessons = try await chapterService.fetchLessons(for: chapterID)
            lessons[chapterID] = chapterLessons
        } catch {
            lessons[chapterID] = Self.sampleLessons(for: chapterID)
        }
    }

    func loadExercises(for chapterID: UUID) async {
        do {
            let chapterExercises = try await chapterService.fetchExercises(for: chapterID)
            exercises[chapterID] = chapterExercises
        } catch {
            exercises[chapterID] = []
        }
    }

    func submitAttempt(exerciseID: UUID, chapterID: UUID, answers: [(questionID: UUID, answer: String, correct: Bool)]) async {
        let attempt = Attempt(
            id: UUID(),
            learnerID: UUID(),
            exerciseID: exerciseID,
            chapterID: chapterID,
            score: Double(answers.filter(\.correct).count) / Double(answers.count),
            totalQuestions: answers.count,
            correctAnswers: answers.filter(\.correct).count,
            startedAt: Date().addingTimeInterval(-120),
            completedAt: Date(),
            items: answers.map { AttemptItem(id: UUID(), attemptID: UUID(), questionID: $0.questionID, givenAnswer: $0.answer, isCorrect: $0.correct, timeTakenSeconds: nil) }
        )

        analyticsService.track(.exerciseCompleted(type: "quiz", chapterID: chapterID, score: attempt.score))
        _ = attempt
    }

    func bookSession(sessionID: UUID) async -> Booking? {
        let booking = Booking(id: UUID(), sessionID: sessionID, learnerID: UUID(), status: .confirmed, bookedAt: Date())
        bookings.append(booking)
        analyticsService.track(.sessionBooked(sessionID: sessionID, tutorID: UUID()))
        return booking
    }

    func cancelBooking(bookingID: UUID) async {
        bookings.removeAll { $0.id == bookingID }
    }

    func sendMessage(to recipientID: UUID, content: String) async {
        let message = ChatMessage(id: UUID(), senderID: UUID(), recipientID: recipientID, content: content, sentAt: Date(), readAt: nil, attachmentURL: nil)
        messages.append(message)
    }

    func hasEntitlement(for productID: String) -> Bool {
        entitlements.contains { $0.productID == productID && $0.isValid }
    }

    func isStageUnlocked(_ chapter: Chapter) -> Bool {
        if !chapter.isPremium { return true }
        return AppState.shared.isPremium || hasEntitlement(for: "com.medlingo.chapter.\(chapter.number)")
    }

    // MARK: - Sample Data (used when backend unavailable)

    static func sampleChapters() -> [Chapter] {
        let stages: [(String, String, Bool)] = [
            ("Word Parts & Foundations", "Prefixes, roots, suffixes, combining forms", false),
            ("Body Organization", "Anatomical orientation and body systems", false),
            ("Integumentary System", "Skin, hair, nails, and disorders", false),
            ("Skeletal System", "Bones, joints, and conditions", true),
            ("Muscular System", "Muscles, movement, disorders", true),
            ("Nervous System", "Brain, spinal cord, nerves", true),
            ("Special Senses", "Eyes, ears, taste, touch", true),
            ("Endocrine System", "Hormones and glands", true),
            ("Cardiovascular System", "Heart and blood vessels", true),
            ("Lymphatic & Immunity", "Immune system and defenses", true),
            ("Respiratory System", "Lungs and breathing", true),
            ("Digestive System", "GI tract and organs", true),
            ("Urinary System", "Kidneys and excretion", true),
            ("Reproductive System", "Male and female anatomy", true),
            ("Clinical Applications", "Cross-system review", true),
        ]
        return stages.enumerated().map { index, data in
            Chapter(id: UUID(), number: index + 1, title: data.0, summary: data.1, estimatedMinutes: Int.random(in: 45...90), isPremium: data.2, coverArtURL: nil, accentColorHex: "", prerequisiteIDs: [], unlockRule: data.2 ? .premium : .free)
        }
    }

    static func sampleLessons(for chapterID: UUID) -> [Lesson] {
        let titles = ["Introduction & Overview", "Key Word Parts", "Structure & Function", "Disorders & Conditions", "Procedures & Treatments", "Abbreviations"]
        return titles.enumerated().map { index, title in
            Lesson(id: UUID(), chapterID: chapterID, orderIndex: index, title: title, content: "Lesson content for \(title)", type: index == 0 ? .explanation : .anatomy, estimatedMinutes: 15, mediaAssets: [])
        }
    }
}
