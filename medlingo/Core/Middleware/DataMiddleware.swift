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
    private let progressService: ProgressServiceProtocol
    private let sessionService: SessionServiceProtocol
    private let entitlementService: EntitlementServiceProtocol
    private let messagingService: MessagingServiceProtocol
    var isRemoteConfigured: Bool

    init(
        chapterService: ChapterServiceProtocol? = nil,
        analyticsService: AnalyticsServiceProtocol? = nil,
        progressService: ProgressServiceProtocol? = nil,
        sessionService: SessionServiceProtocol? = nil,
        entitlementService: EntitlementServiceProtocol? = nil,
        messagingService: MessagingServiceProtocol? = nil,
        isRemoteConfigured: Bool? = nil,
        skipInitialLoad: Bool = false
    ) {
        self.chapterService = chapterService ?? ChapterService()
        self.analyticsService = analyticsService ?? AnalyticsService.shared
        self.progressService = progressService ?? ProgressService()
        self.sessionService = sessionService ?? SessionService()
        self.entitlementService = entitlementService ?? EntitlementService()
        self.messagingService = messagingService ?? MessagingService()
        self.isRemoteConfigured = isRemoteConfigured ?? SupabaseManager.shared.isConfigured
        if !skipInitialLoad {
            Task { await loadInitialData() }
        }
    }

    func loadInitialData() async {
        isLoading = true
        defer { isLoading = false }

        guard isRemoteConfigured else {
            chapters = Self.sampleChapters()
            sessions = Self.sampleSessions()
            return
        }

        do {
            chapters = try await chapterService.fetchChapters()
        } catch {
            chapters = Self.sampleChapters()
            lastError = error.localizedDescription
        }
    }

    func loadLessons(for chapterID: UUID) async {
        guard isRemoteConfigured else {
            lessons[chapterID] = Self.sampleLessons(for: chapterID)
            return
        }
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

        do {
            try await progressService.submitAttempt(attempt)
        } catch {
            lastError = "Failed to submit attempt: \(error.localizedDescription)"
        }

        analyticsService.track(.exerciseCompleted(type: "quiz", chapterID: chapterID, score: attempt.score))
    }

    func loadSessions() async {
        guard isRemoteConfigured else {
            sessions = Self.sampleSessions()
            return
        }
        do {
            sessions = try await sessionService.fetchAvailableSessions()
        } catch {
            sessions = Self.sampleSessions()
        }
    }

    func bookSession(sessionID: UUID) async -> Booking? {
        let learnerID = AppState.shared.currentUserID ?? UUID()

        guard isRemoteConfigured else {
            let booking = Booking(id: UUID(), sessionID: sessionID, learnerID: learnerID, status: .confirmed, bookedAt: Date())
            bookings.append(booking)
            analyticsService.track(.sessionBooked(sessionID: sessionID, tutorID: UUID()))
            return booking
        }

        do {
            let booking = try await sessionService.bookSession(sessionID: sessionID, learnerID: learnerID)
            bookings.append(booking)
            analyticsService.track(.sessionBooked(sessionID: sessionID, tutorID: UUID()))
            return booking
        } catch {
            let booking = Booking(id: UUID(), sessionID: sessionID, learnerID: learnerID, status: .confirmed, bookedAt: Date())
            bookings.append(booking)
            return booking
        }
    }

    func cancelBooking(bookingID: UUID) async {
        do {
            try await sessionService.cancelBooking(bookingID: bookingID)
        } catch {}
        bookings.removeAll { $0.id == bookingID }
    }

    func createSessionRoom(sessionID: UUID) async -> (url: URL, token: String)? {
        guard isRemoteConfigured else {
            let demoURL = URL(string: "\(Config.dailyRoomBaseURL)/medlingo-\(sessionID.uuidString.prefix(8))")!
            return (demoURL, "demo-token-\(UUID().uuidString.prefix(8))")
        }

        do {
            return try await sessionService.createRoomToken(sessionID: sessionID)
        } catch {
            lastError = "Failed to create room: \(error.localizedDescription)"
            return nil
        }
    }

    func loadMessages() async {
        guard let userID = AppState.shared.currentUserID else { return }
        guard isRemoteConfigured else { return }
        do {
            messages = try await messagingService.fetchMessages(for: userID)
        } catch {
            lastError = "Failed to load messages"
        }
    }

    func sendMessage(to recipientID: UUID, content: String) async {
        let senderID = AppState.shared.currentUserID ?? UUID()

        guard isRemoteConfigured else {
            let fallback = ChatMessage(id: UUID(), senderID: senderID, recipientID: recipientID, content: content, sentAt: Date(), readAt: nil, attachmentURL: nil)
            messages.append(fallback)
            return
        }

        do {
            let message = try await messagingService.sendMessage(from: senderID, to: recipientID, content: content)
            messages.append(message)
        } catch {
            let fallback = ChatMessage(id: UUID(), senderID: senderID, recipientID: recipientID, content: content, sentAt: Date(), readAt: nil, attachmentURL: nil)
            messages.append(fallback)
        }
    }

    func loadEntitlements() async {
        guard let userID = AppState.shared.currentUserID else { return }
        do {
            entitlements = try await entitlementService.fetchEntitlements(for: userID)
        } catch {}
    }

    func isStageUnlocked(_ chapter: Chapter) -> Bool {
        true
    }

    // MARK: - Sample Data (used when backend unavailable)

    static func sampleChapters() -> [Chapter] {
        let stages: [(String, String)] = [
            ("Word Parts & Foundations", "Prefixes, roots, suffixes, combining forms"),
            ("Body Organization", "Anatomical orientation and body systems"),
            ("Integumentary System", "Skin, hair, nails, and disorders"),
            ("Skeletal System", "Bones, joints, and conditions"),
            ("Muscular System", "Muscles, movement, disorders"),
            ("Nervous System", "Brain, spinal cord, nerves"),
            ("Special Senses", "Eyes, ears, taste, touch"),
            ("Endocrine System", "Hormones and glands"),
            ("Cardiovascular System", "Heart and blood vessels"),
            ("Lymphatic & Immunity", "Immune system and defenses"),
            ("Respiratory System", "Lungs and breathing"),
            ("Digestive System", "GI tract and organs"),
            ("Urinary System", "Kidneys and excretion"),
            ("Reproductive System", "Male and female anatomy"),
            ("Clinical Applications", "Cross-system review"),
        ]
        return stages.enumerated().map { index, data in
            Chapter(id: UUID(), number: index + 1, title: data.0, summary: data.1, estimatedMinutes: Int.random(in: 45...90), isPremium: false, coverArtURL: nil, accentColorHex: "", prerequisiteIDs: [], unlockRule: .free)
        }
    }

    static func sampleLessons(for chapterID: UUID) -> [Lesson] {
        let titles = ["Introduction & Overview", "Key Word Parts", "Structure & Function", "Disorders & Conditions", "Procedures & Treatments", "Abbreviations"]
        return titles.enumerated().map { index, title in
            Lesson(id: UUID(), chapterID: chapterID, orderIndex: index, title: title, content: "Lesson content for \(title)", type: index == 0 ? .explanation : .anatomy, estimatedMinutes: 15, mediaAssets: [])
        }
    }

    static func sampleSessions() -> [TutorSession] {
        [
            TutorSession(id: UUID(), tutorID: UUID(), title: "Cardiology Terminology Deep Dive", description: "Expert-led session on cardiovascular terms", startsAt: Date().addingTimeInterval(86400), durationMinutes: 45, priceCents: 2500, seatsAvailable: 10, seatsBooked: 3, chapterIDs: [], status: .scheduled),
            TutorSession(id: UUID(), tutorID: UUID(), title: "Anatomy Prefixes & Suffixes", description: "Master word-building strategies", startsAt: Date().addingTimeInterval(172800), durationMinutes: 30, priceCents: 1500, seatsAvailable: 8, seatsBooked: 5, chapterIDs: [], status: .scheduled),
        ]
    }

    func resetForTesting() {
        chapters = []
        lessons = [:]
        exercises = [:]
        progress = [:]
        entitlements = []
        sessions = []
        bookings = []
        messages = []
        isLoading = false
        lastError = nil
    }
}
