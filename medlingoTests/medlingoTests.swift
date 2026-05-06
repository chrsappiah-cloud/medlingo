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
            isPremium: false,
            coverArtURL: nil,
            accentColorHex: "3498DB",
            prerequisiteIDs: [],
            unlockRule: .free
        )
        #expect(chapter.number == 1)
        #expect(chapter.title == "Foundations")
        #expect(chapter.isPremium == false)
        #expect(chapter.unlockRule == .free)
    }

    @Test func chapterUnlockRules() {
        let rules: [Chapter.UnlockRule] = [.free, .sequential, .premium, .institutional]
        #expect(rules.count == 4)
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
            isPremium: true,
            coverArtURL: URL(string: "https://example.com/image.png"),
            accentColorHex: "F1C40F",
            prerequisiteIDs: [UUID(), UUID()],
            unlockRule: .premium
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
        #expect(decoded.isPremium == true)
        #expect(decoded.prerequisiteIDs.count == 2)
    }

    @Test func chapterHashable() {
        let id = UUID()
        let chapter1 = Chapter(id: id, number: 1, title: "A", summary: "", estimatedMinutes: 30, isPremium: false, coverArtURL: nil, accentColorHex: "", prerequisiteIDs: [], unlockRule: .free)
        let chapter2 = Chapter(id: id, number: 1, title: "A", summary: "", estimatedMinutes: 30, isPremium: false, coverArtURL: nil, accentColorHex: "", prerequisiteIDs: [], unlockRule: .free)
        #expect(chapter1 == chapter2)

        var set: Set<Chapter> = []
        set.insert(chapter1)
        set.insert(chapter2)
        #expect(set.count == 1)
    }
}

struct EntitlementModelTests {

    @Test func entitlementValidActive() {
        let entitlement = Entitlement(
            id: UUID(),
            userID: UUID(),
            productID: "com.medlingo.premium.monthly",
            status: .active,
            expiresAt: Date().addingTimeInterval(86400 * 30),
            grantedAt: Date(),
            source: .applePurchase
        )
        #expect(entitlement.isValid == true)
    }

    @Test func entitlementExpired() {
        let entitlement = Entitlement(
            id: UUID(),
            userID: UUID(),
            productID: "com.medlingo.premium.monthly",
            status: .active,
            expiresAt: Date().addingTimeInterval(-86400),
            grantedAt: Date().addingTimeInterval(-86400 * 31),
            source: .applePurchase
        )
        #expect(entitlement.isValid == false)
    }

    @Test func entitlementRevoked() {
        let entitlement = Entitlement(
            id: UUID(),
            userID: UUID(),
            productID: "com.medlingo.premium.yearly",
            status: .revoked,
            expiresAt: Date().addingTimeInterval(86400 * 300),
            grantedAt: Date(),
            source: .adminGrant
        )
        #expect(entitlement.isValid == false)
    }

    @Test func entitlementGracePeriodIsValid() {
        let entitlement = Entitlement(
            id: UUID(),
            userID: UUID(),
            productID: "com.medlingo.premium.monthly",
            status: .gracePeriod,
            expiresAt: Date().addingTimeInterval(86400 * 7),
            grantedAt: Date(),
            source: .applePurchase
        )
        #expect(entitlement.isValid == true)
    }

    @Test func entitlementNoExpiryIsValid() {
        let entitlement = Entitlement(
            id: UUID(),
            userID: UUID(),
            productID: "com.medlingo.chapter.unlock",
            status: .active,
            expiresAt: nil,
            grantedAt: Date(),
            source: .promotional
        )
        #expect(entitlement.isValid == true)
    }

    @Test func entitlementSources() {
        let sources: [Entitlement.EntitlementSource] = [.applePurchase, .adminGrant, .institutional, .promotional]
        #expect(sources.count == 4)
    }

    @Test func entitlementCodable() throws {
        let entitlement = Entitlement(
            id: UUID(),
            userID: UUID(),
            productID: "test.product",
            status: .billingRetry,
            expiresAt: Date(),
            grantedAt: Date(),
            source: .institutional
        )
        let data = try JSONEncoder().encode(entitlement)
        let decoded = try JSONDecoder().decode(Entitlement.self, from: data)
        #expect(decoded.status == .billingRetry)
        #expect(decoded.source == .institutional)
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

struct ProductModelTests {

    @Test func productTypes() {
        let types: [AppProduct.ProductType] = [.subscription, .chapterPack, .sessionBundle, .institutionalPlan]
        #expect(types.count == 4)
    }

    @Test func productCodable() throws {
        let product = AppProduct(
            id: "com.medlingo.premium.monthly",
            name: "Premium Monthly",
            description: "Full access",
            type: .subscription,
            priceCents: 999,
            features: ["All chapters", "Practice lab", "Tutor messaging"]
        )
        let data = try JSONEncoder().encode(product)
        let decoded = try JSONDecoder().decode(AppProduct.self, from: data)
        #expect(decoded.id == product.id)
        #expect(decoded.features.count == 3)
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
            (.purchaseCompleted(productID: "test", revenue: 9.99), "purchase_completed"),
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

struct StoreErrorTests {

    @Test func storeErrorDescriptions() {
        let errors: [StoreError] = [.verificationFailed, .purchaseFailed, .serverVerificationFailed]
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
        #expect(color != nil)
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
