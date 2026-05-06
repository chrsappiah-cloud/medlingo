import Foundation

@MainActor
final class ProgressService: ProgressServiceProtocol {
    private let client: NetworkClientProtocol

    init(client: NetworkClientProtocol? = nil) {
        self.client = client ?? SupabaseManager.shared.networkClient
    }

    func fetchProgress(for userID: UUID) async throws -> [CachedProgress] {
        struct AttemptSummary: Decodable {
            let chapterID: UUID
            let score: Double
            let completedAt: Date?

            enum CodingKeys: String, CodingKey {
                case chapterID = "chapter_id"
                case score
                case completedAt = "completed_at"
            }
        }

        let summaries: [AttemptSummary] = try await client.request(Endpoint(path: "attempts", queryItems: [
            URLQueryItem(name: "learner_id", value: "eq.\(userID.uuidString)"),
            URLQueryItem(name: "select", value: "chapter_id,score,completed_at")
        ]))

        return summaries.map { summary in
            let progress = CachedProgress(chapterID: summary.chapterID, userID: userID)
            progress.masteryScore = summary.score
            return progress
        }
    }

    func submitAttempt(_ attempt: Attempt) async throws {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        let body = try encoder.encode(attempt)
        try await client.request(Endpoint(path: "attempts", method: .post, body: body))
    }

    func recomputeProgress(for userID: UUID) async throws {
        let body = try JSONEncoder().encode(["user_id": userID.uuidString])
        let _: [String: Double] = try await SupabaseManager.shared.functionsClient.request(
            Endpoint(path: "progress-recompute", method: .post, body: body)
        )
    }
}
