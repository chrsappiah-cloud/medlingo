import Foundation

struct TutorSession: Identifiable, Codable, Hashable {
    let id: UUID
    let tutorID: UUID
    let title: String
    let description: String?
    let startsAt: Date
    let durationMinutes: Int
    let priceCents: Int
    let seatsAvailable: Int
    let seatsBooked: Int
    let chapterIDs: [UUID]
    let status: SessionStatus

    enum SessionStatus: String, Codable, Hashable {
        case scheduled
        case live
        case completed
        case cancelled
    }

    var isFull: Bool {
        seatsBooked >= seatsAvailable
    }
}

struct Booking: Identifiable, Codable, Hashable {
    let id: UUID
    let sessionID: UUID
    let learnerID: UUID
    let status: BookingStatus
    let bookedAt: Date

    enum BookingStatus: String, Codable, Hashable {
        case confirmed
        case cancelled
        case completed
        case noShow = "no_show"
    }
}
