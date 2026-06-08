import Foundation
@testable import medlingo

final class SessionServiceMock: SessionServiceProtocol {
    var fetchSessionsResult: Result<[TutorSession], Error> = .success([])
    var bookSessionResult: Result<Booking, Error> = .success(Booking(id: UUID(), sessionID: UUID(), learnerID: UUID(), status: .confirmed, bookedAt: Date()))
    var cancelBookingResult: Result<Void, Error> = .success(())
    var createRoomTokenResult: Result<(url: URL, token: String), Error> = .success((URL(string: "https://example.com/room")!, "token"))

    private(set) var fetchSessionsCallCount = 0
    private(set) var bookSessionCallCount = 0
    private(set) var lastBookedSessionID: UUID?
    private(set) var cancelBookingCallCount = 0
    private(set) var lastCancelledBookingID: UUID?
    private(set) var createRoomTokenCallCount = 0
    private(set) var lastRoomSessionID: UUID?

    func fetchAvailableSessions() async throws -> [TutorSession] {
        fetchSessionsCallCount += 1
        return try fetchSessionsResult.get()
    }

    func bookSession(sessionID: UUID, learnerID: UUID) async throws -> Booking {
        bookSessionCallCount += 1
        lastBookedSessionID = sessionID
        return try bookSessionResult.get()
    }

    func cancelBooking(bookingID: UUID) async throws {
        cancelBookingCallCount += 1
        lastCancelledBookingID = bookingID
        try cancelBookingResult.get()
    }

    func createRoomToken(sessionID: UUID) async throws -> (url: URL, token: String) {
        createRoomTokenCallCount += 1
        lastRoomSessionID = sessionID
        return try createRoomTokenResult.get()
    }
}
