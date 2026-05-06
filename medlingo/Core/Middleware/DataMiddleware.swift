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
    private let progressService: ProgressService
    private let sessionService: SessionService
    private let entitlementService: EntitlementService
    private let messagingService: MessagingService

    private init() {
        self.chapterService = ChapterService()
        self.analyticsService = AnalyticsService.shared
        self.progressService = ProgressService()
        self.sessionService = SessionService()
        self.entitlementService = EntitlementService()
        self.messagingService = MessagingService()
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

        do {
            try await progressService.submitAttempt(attempt)
        } catch {
            lastError = "Failed to submit attempt: \(error.localizedDescription)"
        }

        analyticsService.track(.exerciseCompleted(type: "quiz", chapterID: chapterID, score: attempt.score))
    }

    func loadSessions() async {
        do {
            sessions = try await sessionService.fetchAvailableSessions()
        } catch {
            sessions = Self.sampleSessions()
        }
    }

    func bookSession(sessionID: UUID) async -> Booking? {
        do {
            let booking = try await sessionService.bookSession(sessionID: sessionID, learnerID: AppState.shared.currentUserID ?? UUID())
            bookings.append(booking)
            analyticsService.track(.sessionBooked(sessionID: sessionID, tutorID: UUID()))
            return booking
        } catch {
            let booking = Booking(id: UUID(), sessionID: sessionID, learnerID: UUID(), status: .confirmed, bookedAt: Date())
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
        do {
            return try await sessionService.createRoomToken(sessionID: sessionID)
        } catch {
            lastError = "Failed to create room: \(error.localizedDescription)"
            return nil
        }
    }

    func loadMessages() async {
        guard let userID = AppState.shared.currentUserID else { return }
        do {
            messages = try await messagingService.fetchMessages(for: userID)
        } catch {
            lastError = "Failed to load messages"
        }
    }

    func sendMessage(to recipientID: UUID, content: String) async {
        guard let senderID = AppState.shared.currentUserID else { return }
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

    func verifyPurchase(transactionID: String, productID: String, signedPayload: String) async {
        guard let userID = AppState.shared.currentUserID else { return }
        do {
            let entitlement = try await entitlementService.verifyPurchase(
                transactionID: transactionID,
                productID: productID,
                userID: userID,
                signedPayload: signedPayload
            )
            if let existing = entitlements.firstIndex(where: { $0.productID == entitlement.productID }) {
                entitlements[existing] = entitlement
            } else {
                entitlements.append(entitlement)
            }
        } catch {
            lastError = "Purchase verification failed"
        }
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

    static func sampleSessions() -> [TutorSession] {
        [
            TutorSession(id: UUID(), tutorID: UUID(), title: "Cardiology Terminology Deep Dive", description: "Expert-led session on cardiovascular terms", startsAt: Date().addingTimeInterval(86400), durationMinutes: 45, priceCents: 2500, seatsAvailable: 10, seatsBooked: 3, chapterIDs: [], status: .scheduled),
            TutorSession(id: UUID(), tutorID: UUID(), title: "Anatomy Prefixes & Suffixes", description: "Master word-building strategies", startsAt: Date().addingTimeInterval(172800), durationMinutes: 30, priceCents: 1500, seatsAvailable: 8, seatsBooked: 5, chapterIDs: [], status: .scheduled),
        ]
    }
}
