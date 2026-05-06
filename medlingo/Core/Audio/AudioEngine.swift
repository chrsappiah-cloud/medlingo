import Foundation
import AVFoundation

@MainActor
@Observable
final class AudioEngine: NSObject {
    static let shared = AudioEngine()

    private var audioPlayer: AVAudioPlayer?
    private let speechSynthesizer = AVSpeechSynthesizer()
    private var audioSession: AVAudioSession { .sharedInstance() }

    private(set) var isPlaying = false
    private(set) var isLoading = false
    private(set) var currentTermPlaying: String?

    private var audioCache: [String: URL] = [:]

    override init() {
        super.init()
        configureAudioSession()
    }

    private func configureAudioSession() {
        do {
            try audioSession.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try audioSession.setActive(true)
        } catch {
            print("AudioEngine: Failed to configure audio session: \(error)")
        }
    }

    // MARK: - Text-to-Speech (offline fallback)

    func speakTerm(_ term: String, language: String = "en-US") {
        stopPlayback()
        currentTermPlaying = term
        isPlaying = true

        let utterance = AVSpeechUtterance(string: term)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.8
        utterance.pitchMultiplier = 1.0
        utterance.preUtteranceDelay = 0.1
        utterance.postUtteranceDelay = 0.2

        speechSynthesizer.delegate = self
        speechSynthesizer.speak(utterance)
    }

    // MARK: - Audio File Playback (from Supabase Storage or local cache)

    func playAudioFromURL(_ url: URL, term: String) async {
        stopPlayback()
        isLoading = true
        currentTermPlaying = term

        do {
            let localURL: URL
            if let cached = audioCache[term] {
                localURL = cached
            } else {
                let (data, _) = try await URLSession.shared.data(from: url)
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(term).mp3")
                try data.write(to: tempURL)
                audioCache[term] = tempURL
                localURL = tempURL
            }

            isLoading = false
            audioPlayer = try AVAudioPlayer(contentsOf: localURL)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            isPlaying = true
        } catch {
            isLoading = false
            isPlaying = false
            speakTerm(term)
        }
    }

    // MARK: - Playback from local bundle

    func playBundledAudio(named filename: String, term: String) {
        stopPlayback()
        currentTermPlaying = term

        guard let url = Bundle.main.url(forResource: filename, withExtension: nil) else {
            speakTerm(term)
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            isPlaying = true
        } catch {
            speakTerm(term)
        }
    }

    // MARK: - Controls

    func stopPlayback() {
        speechSynthesizer.stopSpeaking(at: .immediate)
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        currentTermPlaying = nil
    }

    func clearCache() {
        for (_, url) in audioCache {
            try? FileManager.default.removeItem(at: url)
        }
        audioCache.removeAll()
    }
}

extension AudioEngine: AVSpeechSynthesizerDelegate {
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            isPlaying = false
            currentTermPlaying = nil
        }
    }
}

extension AudioEngine: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            isPlaying = false
            currentTermPlaying = nil
        }
    }
}
