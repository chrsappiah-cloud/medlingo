import Foundation

struct AppUser: Identifiable, Codable, Hashable {
    let id: UUID
    let email: String
    let displayName: String
    let role: UserRole
    let status: UserStatus
    let institutionID: UUID?
    let createdAt: Date
    let updatedAt: Date

    enum UserRole: String, Codable, Hashable, CaseIterable {
        case learner
        case tutor
        case administrator
        case superAdmin = "super_admin"
    }

    enum UserStatus: String, Codable, Hashable {
        case active
        case suspended
        case pendingVerification = "pending_verification"
        case blocked
    }
}

struct LearnerProfile: Identifiable, Codable, Hashable {
    let id: UUID
    let userID: UUID
    var studyGoal: String?
    var currentStreak: Int
    var longestStreak: Int
    var onboardingCompleted: Bool
    var level: Int
    var totalXP: Int
}

struct TutorProfile: Identifiable, Codable, Hashable {
    let id: UUID
    let userID: UUID
    var bio: String
    var subjects: [String]
    var isVerified: Bool
    var hourlyRateCents: Int
    var availabilityPolicy: String?
    var rating: Double
    var totalSessions: Int
}
