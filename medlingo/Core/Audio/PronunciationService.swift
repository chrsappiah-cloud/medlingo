import Foundation

protocol PronunciationServiceProtocol {
    func pronounce(term: String) async
    func fetchAudioURL(for term: String) async -> URL?
    func preloadAudio(for terms: [String]) async
}

@MainActor
final class PronunciationService: PronunciationServiceProtocol {
    static let shared = PronunciationService()

    private let audioEngine = AudioEngine.shared
    private let storageBaseURL: URL
    private var urlCache: [String: URL] = [:]

    private init() {
        self.storageBaseURL = SupabaseManager.shared.projectURL
            .appendingPathComponent("storage/v1/object/public/audio/pronunciations")
    }

    func pronounce(term: String) async {
        let sanitized = term
            .replacingOccurrences(of: "/", with: "")
            .replacingOccurrences(of: "-", with: "")
            .lowercased()
            .trimmingCharacters(in: .whitespaces)

        guard SupabaseManager.shared.isConfigured else {
            audioEngine.speakTerm(term)
            return
        }

        if let cachedURL = urlCache[sanitized] {
            await audioEngine.playAudioFromURL(cachedURL, term: term)
        } else if let remoteURL = await fetchAudioURL(for: sanitized) {
            urlCache[sanitized] = remoteURL
            await audioEngine.playAudioFromURL(remoteURL, term: term)
        } else {
            audioEngine.speakTerm(term)
        }
    }

    func fetchAudioURL(for term: String) async -> URL? {
        guard SupabaseManager.shared.isConfigured else { return nil }

        let url = storageBaseURL.appendingPathComponent("\(term).mp3")
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                return url
            }
        } catch {}
        return nil
    }

    func preloadAudio(for terms: [String]) async {
        guard SupabaseManager.shared.isConfigured else { return }

        await withTaskGroup(of: Void.self) { group in
            for term in terms {
                group.addTask {
                    let sanitized = term.lowercased().replacingOccurrences(of: "/", with: "").replacingOccurrences(of: "-", with: "")
                    if let url = await self.fetchAudioURL(for: sanitized) {
                        await MainActor.run { self.urlCache[sanitized] = url }
                    }
                }
            }
        }
    }

    func stopPlayback() {
        audioEngine.stopPlayback()
    }
}
