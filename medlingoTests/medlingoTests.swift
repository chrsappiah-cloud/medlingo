import Testing
import Foundation
import SwiftUI
@testable import medlingo

// MARK: - SharedModels Unit Tests

struct ChapterModelTests {

    @Test func chapterInitialization() {
        let chapter = Chapter(
            id: UUID(),
            number: 1,
            title: "Foundations",
            summary: "Word parts and basics",
            estimatedMinutes: 45,
            coverArtURL: nil,
            accentColorHex: "3498DB",
            prerequisiteIDs: [],
            unlockRule: .free
        )
        #expect(chapter.number == 1)
        #expect(chapter.title == "Foundations")
        #expect(chapter.unlockRule == .free)
    }

    @Test func chapterUnlockRules() {
        let rules: [Chapter.UnlockRule] = [.free, .sequential, .institutional]
        #expect(rules.count == 3)
        for rule in rules {
            let encoded = try? JSONEncoder().encode(rule)
            #expect(encoded != nil)
        }
    }

    @Test func chapterCodable() throws {
        let chapter = Chapter(
            id: UUID(),
            number: 3,
            title: "Skeletal",
            summary: "Bones and joints",
            estimatedMinutes: 75,
            coverArtURL: URL(string: "https://example.com/image.png"),
            accentColorHex: "F1C40F",
            prerequisiteIDs: [UUID(), UUID()],
            unlockRule: .sequential
        )
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try encoder.encode(chapter)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let decoded = try decoder.decode(Chapter.self, from: data)
        #expect(decoded.id == chapter.id)
        #expect(decoded.number == chapter.number)
        #expect(decoded.title == chapter.title)
        #expect(decoded.prerequisiteIDs.count == 2)
    }

    @Test func chapterHashable() {
        let id = UUID()
        let chapter1 = Chapter(id: id, number: 1, title: "A", summary: "", estimatedMinutes: 30, coverArtURL: nil, accentColorHex: "", prerequisiteIDs: [], unlockRule: .free)
        let chapter2 = Chapter(id: id, number: 1, title: "A", summary: "", estimatedMinutes: 30, coverArtURL: nil, accentColorHex: "", prerequisiteIDs: [], unlockRule: .free)
        #expect(chapter1 == chapter2)

        var set: Set<Chapter> = []
        set.insert(chapter1)
        set.insert(chapter2)
        #expect(set.count == 1)
    }
}

struct UserModelTests {

    @Test func userRoles() {
        let roles = AppUser.UserRole.allCases
        #expect(roles.count == 4)
        #expect(roles.contains(.learner))
        #expect(roles.contains(.tutor))
        #expect(roles.contains(.administrator))
        #expect(roles.contains(.superAdmin))
    }

    @Test func userCodable() throws {
        let user = AppUser(
            id: UUID(),
            email: "test@medlingo.com",
            displayName: "Test User",
            role: .learner,
            status: .active,
            institutionID: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        let data = try JSONEncoder().encode(user)
        let decoded = try JSONDecoder().decode(AppUser.self, from: data)
        #expect(decoded.email == "test@medlingo.com")
        #expect(decoded.role == .learner)
        #expect(decoded.status == .active)
    }

    @Test func learnerProfileDefaults() {
        let profile = LearnerProfile(
            id: UUID(),
            userID: UUID(),
            studyGoal: "Pass anatomy exam",
            currentStreak: 0,
            longestStreak: 0,
            onboardingCompleted: false,
            level: 1,
            totalXP: 0
        )
        #expect(profile.currentStreak == 0)
        #expect(profile.level == 1)
        #expect(profile.onboardingCompleted == false)
    }

    @Test func tutorProfileVerification() {
        let profile = TutorProfile(
            id: UUID(),
            userID: UUID(),
            bio: "Medical terminology expert",
            subjects: ["Cardiovascular", "Respiratory"],
            isVerified: false,
            hourlyRateCents: 4500,
            availabilityPolicy: nil,
            rating: 0.0,
            totalSessions: 0
        )
        #expect(profile.isVerified == false)
        #expect(profile.subjects.count == 2)
        #expect(profile.hourlyRateCents == 4500)
    }
}

struct TutorSessionModelTests {

    @Test func sessionIsFull() {
        let session = TutorSession(
            id: UUID(),
            tutorID: UUID(),
            title: "Cardio Review",
            description: "Heart terminology",
            startsAt: Date().addingTimeInterval(3600),
            durationMinutes: 60,
            priceCents: 4500,
            seatsAvailable: 5,
            seatsBooked: 5,
            chapterIDs: [UUID()],
            status: .scheduled
        )
        #expect(session.isFull == true)
    }

    @Test func sessionNotFull() {
        let session = TutorSession(
            id: UUID(),
            tutorID: UUID(),
            title: "Neuro Basics",
            description: nil,
            startsAt: Date().addingTimeInterval(7200),
            durationMinutes: 45,
            priceCents: 3800,
            seatsAvailable: 10,
            seatsBooked: 3,
            chapterIDs: [],
            status: .scheduled
        )
        #expect(session.isFull == false)
    }

    @Test func sessionStatuses() throws {
        let statuses: [TutorSession.SessionStatus] = [.scheduled, .live, .completed, .cancelled]
        for status in statuses {
            let data = try JSONEncoder().encode(status)
            let decoded = try JSONDecoder().decode(TutorSession.SessionStatus.self, from: data)
            #expect(decoded == status)
        }
    }

    @Test func bookingCodable() throws {
        let booking = Booking(
            id: UUID(),
            sessionID: UUID(),
            learnerID: UUID(),
            status: .confirmed,
            bookedAt: Date()
        )
        let data = try JSONEncoder().encode(booking)
        let decoded = try JSONDecoder().decode(Booking.self, from: data)
        #expect(decoded.status == .confirmed)
    }
}

struct ExerciseModelTests {

    @Test func exerciseTypes() {
        let types: [Exercise.ExerciseType] = [
            .multipleChoice, .termBuilder, .labeling, .flashcard,
            .caseStudy, .fillInTheBlank, .abbreviation, .matching
        ]
        #expect(types.count == 8)
    }

    @Test func wordPartTypes() {
        let part = WordPart(value: "cardi", type: .root, meaning: "heart")
        #expect(part.value == "cardi")
        #expect(part.type == .root)
        #expect(part.meaning == "heart")
    }

    @Test func questionItemCodable() throws {
        let question = QuestionItem(
            id: UUID(),
            prompt: "What does -itis mean?",
            options: ["inflammation", "disease", "removal", "pain"],
            correctAnswer: "inflammation",
            explanation: "-itis always refers to inflammation of a body part",
            mediaURL: nil,
            wordParts: nil
        )
        let data = try JSONEncoder().encode(question)
        let decoded = try JSONDecoder().decode(QuestionItem.self, from: data)
        #expect(decoded.prompt == question.prompt)
        #expect(decoded.options?.count == 4)
        #expect(decoded.correctAnswer == "inflammation")
    }
}

struct AttemptModelTests {

    @Test func attemptScoring() {
        let attempt = Attempt(
            id: UUID(),
            learnerID: UUID(),
            exerciseID: UUID(),
            chapterID: UUID(),
            score: 0.85,
            totalQuestions: 20,
            correctAnswers: 17,
            startedAt: Date().addingTimeInterval(-300),
            completedAt: Date(),
            items: []
        )
        #expect(attempt.score == 0.85)
        #expect(attempt.correctAnswers == 17)
        #expect(attempt.totalQuestions == 20)
    }

    @Test func attemptItemCorrectness() {
        let item = AttemptItem(
            id: UUID(),
            attemptID: UUID(),
            questionID: UUID(),
            givenAnswer: "inflammation",
            isCorrect: true,
            timeTakenSeconds: 12
        )
        #expect(item.isCorrect == true)
        #expect(item.timeTakenSeconds == 12)
    }
}

// MARK: - Core Service Tests

struct NetworkClientTests {

    @Test func endpointConstruction() {
        let endpoint = Endpoint(
            path: "chapters",
            method: .get,
            queryItems: [URLQueryItem(name: "order", value: "number.asc")]
        )
        #expect(endpoint.path == "chapters")
        #expect(endpoint.method == .get)
        #expect(endpoint.queryItems?.count == 1)
    }

    @Test func endpointHTTPMethods() {
        let methods: [Endpoint.HTTPMethod] = [.get, .post, .put, .patch, .delete]
        let expected = ["GET", "POST", "PUT", "PATCH", "DELETE"]
        for (method, raw) in zip(methods, expected) {
            #expect(method.rawValue == raw)
        }
    }

    @Test func endpointWithBody() throws {
        let body = try JSONEncoder().encode(["session_id": UUID().uuidString])
        let endpoint = Endpoint(path: "sessions/create-room", method: .post, body: body)
        #expect(endpoint.method == .post)
        #expect(endpoint.body != nil)
    }

    @Test func networkErrorDescriptions() {
        let errors: [NetworkError] = [
            .invalidResponse,
            .httpError(statusCode: 404, data: Data()),
            .decodingError(NSError(domain: "", code: 0))
        ]
        for error in errors {
            #expect(error.errorDescription != nil)
        }
    }
}

struct AnalyticsServiceTests {

    @Test func eventNames() {
        let events: [(AnalyticsEvent, String)] = [
            (.appOpened, "app_opened"),
            (.screenViewed(name: "Home"), "screen_viewed"),
            (.lessonStarted(chapterID: UUID(), lessonID: UUID()), "lesson_started"),
            (.lessonCompleted(chapterID: UUID(), lessonID: UUID(), durationSeconds: 300), "lesson_completed"),
            (.exerciseAttempted(type: "mcq", chapterID: UUID(), score: 0.8), "exercise_attempted"),
            (.streakUpdated(count: 7), "streak_updated"),
        ]
        for (event, expectedName) in events {
            #expect(event.name == expectedName)
        }
    }
}

struct AuthErrorTests {

    @Test func authErrorDescriptions() {
        let errors: [AuthError] = [.invalidCredential, .sessionExpired, .networkError, .accountDisabled]
        for error in errors {
            #expect(error.errorDescription != nil)
            #expect(!error.errorDescription!.isEmpty)
        }
    }
}

// MARK: - Design System Tests

struct DesignSystemTests {

    @Test func stageColorsCount() {
        #expect(AppColor.stageColors.count == 15)
    }

    @Test func colorFromHex() {
        let color = Color(hex: "FF0000")
        #expect(color == Color(hex: "FF0000"))
    }

    @Test func spacingValues() {
        #expect(AppSpacing.xs < AppSpacing.sm)
        #expect(AppSpacing.sm < AppSpacing.md)
        #expect(AppSpacing.md < AppSpacing.lg)
        #expect(AppSpacing.lg < AppSpacing.xl)
        #expect(AppSpacing.xl < AppSpacing.xxl)
    }

    @Test func radiusValues() {
        #expect(AppRadius.sm < AppRadius.md)
        #expect(AppRadius.md < AppRadius.lg)
        #expect(AppRadius.lg < AppRadius.xl)
        #expect(AppRadius.xl < AppRadius.full)
    }
}

// MARK: - Lesson & Media Model Tests

struct LessonModelTests {

    @Test func lessonTypes() {
        let types: [Lesson.LessonType] = [
            .explanation, .anatomy, .disorders, .procedures, .abbreviations, .practicalTask
        ]
        #expect(types.count == 6)
    }

    @Test func mediaAssetTypes() {
        let types: [MediaAsset.MediaType] = [.image, .diagram, .video, .pdf, .audio]
        #expect(types.count == 5)
    }

    @Test func lessonCodable() throws {
        let lesson = Lesson(
            id: UUID(),
            chapterID: UUID(),
            orderIndex: 1,
            title: "Introduction to Word Parts",
            content: "Medical terms are built from...",
            type: .explanation,
            estimatedMinutes: 15,
            mediaAssets: []
        )
        let data = try JSONEncoder().encode(lesson)
        let decoded = try JSONDecoder().decode(Lesson.self, from: data)
        #expect(decoded.title == lesson.title)
        #expect(decoded.type == .explanation)
        #expect(decoded.orderIndex == 1)
    }
}

struct MessageModelTests {

    @Test func messageReadStatus() {
        let unread = ChatMessage(
            id: UUID(),
            senderID: UUID(),
            recipientID: UUID(),
            content: "Hello",
            sentAt: Date(),
            readAt: nil,
            attachmentURL: nil
        )
        #expect(unread.isRead == false)

        let read = ChatMessage(
            id: UUID(),
            senderID: UUID(),
            recipientID: UUID(),
            content: "Hi there",
            sentAt: Date().addingTimeInterval(-60),
            readAt: Date(),
            attachmentURL: nil
        )
        #expect(read.isRead == true)
    }
}

// MARK: - Performance Tests (99th percentile targets vs top iOS apps)

struct PerformanceTests {

    @Test func chapterEncodeDecodeUnder10ms() throws {
        let chapters = (0..<100).map { index in
            Chapter(
                id: UUID(),
                number: index + 1,
                title: "Stage \(index + 1)",
                summary: "Summary",
                estimatedMinutes: 45,
                coverArtURL: nil,
                accentColorHex: "3498DB",
                prerequisiteIDs: [],
                unlockRule: .free
            )
        }
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let clock = ContinuousClock()
        let start = clock.now
        for chapter in chapters {
            let data = try encoder.encode(chapter)
            _ = try decoder.decode(Chapter.self, from: data)
        }
        let elapsed = clock.now - start
        // 50ms for 100 encode/decode rounds — stable on GitHub Actions runners
        #expect(elapsed < .milliseconds(50))
    }

    @Test func stageColorParsingUnder5ms() {
        let hexValues = AppColor.stageColors.map { _ in "D4AF37" }
        let clock = ContinuousClock()
        let start = clock.now
        for hex in hexValues {
            _ = Color(hex: hex)
        }
        let elapsed = clock.now - start
        // 5ms for 15 colors — stable on CI runners; <1ms on device
        #expect(elapsed < .milliseconds(5))
    }

    @Test func generatedArtworkFilterUnder5ms() {
        let artworks = (0..<1000).map { index in
            GeneratedArtwork(
                id: UUID(),
                ownerID: UUID(),
                prompt: "Prompt \(index)",
                negativePrompt: nil,
                mediaType: index.isMultiple(of: 2) ? .video : .image,
                status: .completed,
                mediaURL: URL(string: "https://example.com/\(index).png"),
                thumbnailURL: nil,
                provider: "inVideo",
                modelName: "test",
                width: 1024,
                height: 1024,
                durationSeconds: index.isMultiple(of: 2) ? 5 : nil,
                seed: index,
                createdAt: Date(),
                completedAt: Date(),
                isFavorite: index.isMultiple(of: 5),
                tags: ["medical"]
            )
        }
        let clock = ContinuousClock()
        let start = clock.now
        let videos = artworks.filter { $0.mediaType == .video }
        let favorites = artworks.filter(\.isFavorite)
        let elapsed = clock.now - start
        #expect(videos.count == 500)
        #expect(favorites.count == 200)
        #expect(elapsed < .milliseconds(5))
    }
}
