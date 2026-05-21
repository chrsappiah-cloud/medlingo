import SwiftUI
import AVKit
import AVFoundation

struct AITutorSessionView: View {
    let topic: String
    let chapterContext: String

    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = AITutorViewModel()

    var body: some View {
        VStack(spacing: 0) {
            header
            Spacer(minLength: 0)
            contentArea
            Spacer(minLength: 0)
            bottomControls
        }
        .background(AppColor.background)
        .preferredColorScheme(.dark)
        .task { await viewModel.startSession(topic: topic, context: chapterContext) }
        .onDisappear { viewModel.stopAll() }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("AI Tutor Session")
                    .font(AppTypography.headline)
                    .foregroundColor(AppColor.textPrimary)
                Text(topic)
                    .font(AppTypography.caption1)
                    .foregroundColor(AppColor.textSecondary)
                    .lineLimit(1)
            }
            Spacer()
            statusBadge
            Button { viewModel.stopAll(); dismiss() } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(AppColor.textTertiary)
            }
        }
        .padding(AppSpacing.md)
        .background(AppColor.surface)
    }

    @ViewBuilder
    private var statusBadge: some View {
        let (text, color) = statusInfo
        HStack(spacing: AppSpacing.xxs) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
                .shadow(color: color.opacity(0.6), radius: 3)
            Text(text)
                .font(AppTypography.caption2)
                .foregroundColor(color)
        }
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, AppSpacing.xxs)
        .background(color.opacity(0.12))
        .clipShape(Capsule())
    }

    private var statusInfo: (String, Color) {
        switch viewModel.phase {
        case .idle: return ("Ready", AppColor.textTertiary)
        case .generatingScript: return ("Writing Script...", AppColor.streakOrange)
        case .generatingVideo: return ("Preparing...", AppColor.streakOrange)
        case .polling: return ("Loading...", AppColor.gold)
        case .ready: return ("AI Tutor Ready", AppColor.emerald)
        case .playing: return ("Speaking", AppColor.emerald)
        case .error: return ("Error", AppColor.error)
        }
    }

    @ViewBuilder
    private var contentArea: some View {
        switch viewModel.phase {
        case .idle, .generatingScript, .generatingVideo, .polling:
            loadingView
        case .ready, .playing:
            teachingView
        case .error(let message):
            errorView(message)
        }
    }

    private var loadingView: some View {
        VStack(spacing: AppSpacing.lg) {
            avatarPreview
            progressIndicator
            Text(loadingMessage)
                .font(AppTypography.body)
                .foregroundColor(AppColor.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(AppSpacing.xl)
    }

    private var avatarPreview: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [AppColor.diamond.opacity(0.3), AppColor.gold.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 120, height: 120)

            Image(systemName: "person.crop.circle.badge.questionmark.fill")
                .font(.system(size: 56))
                .foregroundStyle(AppColor.diamond, AppColor.gold)

            if viewModel.phase != .idle {
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(AppColor.diamond, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 130, height: 130)
                    .rotationEffect(.degrees(viewModel.spinnerAngle))
                    .animation(.linear(duration: 1.5).repeatForever(autoreverses: false), value: viewModel.spinnerAngle)
                    .onAppear { viewModel.spinnerAngle = 360 }
            }
        }
    }

    private var progressIndicator: some View {
        VStack(spacing: AppSpacing.xs) {
            ProgressView(value: viewModel.progress)
                .tint(AppColor.diamond)
                .frame(width: 200)
            Text("\(Int(viewModel.progress * 100))%")
                .font(AppTypography.caption2)
                .foregroundColor(AppColor.textTertiary)
        }
    }

    private var loadingMessage: String {
        switch viewModel.phase {
        case .generatingScript: return "Crafting a personalized lesson on\n\"\(topic)\"..."
        case .generatingVideo: return "Your AI tutor is preparing to teach..."
        case .polling: return "Almost ready..."
        default: return "Initializing..."
        }
    }

    private var teachingView: some View {
        VStack(spacing: AppSpacing.md) {
            avatarSpeakingView
            scriptView
        }
    }

    private var avatarSpeakingView: some View {
        VStack(spacing: AppSpacing.sm) {
            ZStack {
                RoundedRectangle(cornerRadius: AppRadius.lg)
                    .fill(
                        LinearGradient(
                            colors: [Color(white: 0.05), Color(red: 0.02, green: 0.05, blue: 0.15)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .aspectRatio(16/9, contentMode: .fit)

                VStack(spacing: AppSpacing.sm) {
                    ZStack {
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [AppColor.diamond, AppColor.gold],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: viewModel.isSpeaking ? 3 : 1.5
                            )
                            .frame(width: 96, height: 96)
                            .scaleEffect(viewModel.isSpeaking ? 1.04 : 1.0)
                            .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: viewModel.isSpeaking)

                        Image("dr_elena_chen")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 88, height: 88)
                            .clipShape(Circle())
                    }

                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: viewModel.isSpeaking ? "waveform" : "waveform.slash")
                            .foregroundColor(viewModel.isSpeaking ? AppColor.emerald : AppColor.textTertiary)
                            .symbolEffect(.variableColor, isActive: viewModel.isSpeaking)
                        Text(viewModel.avatarName)
                            .font(AppTypography.caption1)
                            .foregroundColor(AppColor.textSecondary)
                    }

                    if viewModel.isSpeaking {
                        SpeechWaveformView()
                            .frame(height: 20)
                            .padding(.horizontal, AppSpacing.xl)
                    }
                }
            }
            .padding(.horizontal, AppSpacing.md)
        }
    }

    private var scriptView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    ForEach(Array(viewModel.sentences.enumerated()), id: \.offset) { index, sentence in
                        Text(sentence)
                            .font(AppTypography.body)
                            .foregroundColor(index == viewModel.currentSentenceIndex ? AppColor.textPrimary : AppColor.textTertiary)
                            .fontWeight(index == viewModel.currentSentenceIndex ? .medium : .regular)
                            .lineSpacing(3)
                            .padding(.vertical, 2)
                            .id(index)
                            .animation(.easeInOut(duration: 0.3), value: viewModel.currentSentenceIndex)
                    }
                }
                .padding(AppSpacing.md)
            }
            .frame(maxHeight: 160)
            .background(AppColor.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
            .padding(.horizontal, AppSpacing.md)
            .onChange(of: viewModel.currentSentenceIndex) { _, newIndex in
                withAnimation {
                    proxy.scrollTo(newIndex, anchor: .center)
                }
            }
        }
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: AppSpacing.lg) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(AppColor.error)
            Text("Generation Failed")
                .font(AppTypography.title2)
                .foregroundColor(AppColor.textPrimary)
            Text(message)
                .font(AppTypography.body)
                .foregroundColor(AppColor.textSecondary)
                .multilineTextAlignment(.center)
            PrimaryButton(title: "Retry") {
                Task { await viewModel.startSession(topic: topic, context: chapterContext) }
            }
            .frame(width: 150)
        }
        .padding(AppSpacing.xl)
    }

    private var bottomControls: some View {
        HStack(spacing: AppSpacing.lg) {
            if viewModel.phase == .playing || viewModel.phase == .ready {
                controlButton(icon: "backward.fill", label: "Prev") {
                    viewModel.previousSentence()
                }
                controlButton(
                    icon: viewModel.isSpeaking ? "pause.fill" : "play.fill",
                    label: viewModel.isSpeaking ? "Pause" : "Play"
                ) {
                    viewModel.togglePlayback()
                }
                controlButton(icon: "forward.fill", label: "Next") {
                    viewModel.nextSentence()
                }
                controlButton(icon: "arrow.clockwise", label: "Replay") {
                    viewModel.replay()
                }
                Spacer()
                controlButton(icon: "tortoise.fill", label: viewModel.speechRate == .slow ? "Slow" : "Normal") {
                    viewModel.toggleSpeed()
                }
            } else {
                Spacer()
            }

            controlButton(icon: "arrow.uturn.backward", label: "New Topic") {
                Task { await viewModel.startSession(topic: topic, context: chapterContext) }
            }
        }
        .padding(.vertical, AppSpacing.md)
        .padding(.horizontal, AppSpacing.lg)
        .background(AppColor.surface)
    }

    private func controlButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(AppColor.textPrimary)
                    .frame(width: 44, height: 36)
                Text(label)
                    .font(.system(size: 9))
                    .foregroundColor(AppColor.textTertiary)
            }
        }
    }
}

// MARK: - Speech Waveform Animation

struct SpeechWaveformView: View {
    @State private var animating = false

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<12, id: \.self) { i in
                RoundedRectangle(cornerRadius: 2)
                    .fill(AppColor.diamond.opacity(0.7))
                    .frame(width: 3, height: animating ? CGFloat.random(in: 4...18) : 4)
                    .animation(
                        .easeInOut(duration: Double.random(in: 0.3...0.6))
                        .repeatForever(autoreverses: true)
                        .delay(Double(i) * 0.05),
                        value: animating
                    )
            }
        }
        .onAppear { animating = true }
    }
}

// MARK: - View Model

@MainActor
@Observable
final class AITutorViewModel: NSObject, AVSpeechSynthesizerDelegate {
    enum Phase: Equatable {
        case idle
        case generatingScript
        case generatingVideo
        case polling
        case ready
        case playing
        case error(String)

        static func == (lhs: Phase, rhs: Phase) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle), (.generatingScript, .generatingScript),
                 (.generatingVideo, .generatingVideo), (.polling, .polling),
                 (.ready, .ready), (.playing, .playing):
                return true
            case (.error(let a), .error(let b)):
                return a == b
            default:
                return false
            }
        }
    }

    enum SpeechRate {
        case normal, slow
        var value: Float {
            switch self {
            case .normal: return AVSpeechUtteranceDefaultSpeechRate * 0.92
            case .slow: return AVSpeechUtteranceDefaultSpeechRate * 0.7
            }
        }
    }

    var phase: Phase = .idle
    var progress: Double = 0
    var spinnerAngle: Double = 0
    var isSpeaking = false
    var isPlaying = false
    var currentScript: String?
    var sentences: [String] = []
    var currentSentenceIndex: Int = 0
    var avatarName: String = "Dr. Elena Chen"
    var speechRate: SpeechRate = .normal

    // Legacy player kept for video backdrop if backend provides one
    var player: AVPlayer?

    private let service = AIVideoGenerationService.shared
    private let synthesizer = AVSpeechSynthesizer()
    private var currentVideoId: String?

    override init() {
        super.init()
        synthesizer.delegate = self
        configureAudioSession()
    }

    func startSession(topic: String, context: String) async {
        stopAll()
        phase = .generatingScript
        progress = 0.1

        do {
            let script = try await service.generateScript(for: topic, chapterContext: context)
            currentScript = script
            sentences = splitIntoSentences(script)
            currentSentenceIndex = 0
            progress = 0.5
            phase = .generatingVideo

            let avatars = try await service.fetchAvailableAvatars()
            if let avatar = avatars.first {
                avatarName = avatar.name
            }

            progress = 0.8

            // Generate video (plays as visual backdrop)
            let response = try await service.generateVideo(topic: topic, script: script, avatar: avatars.first ?? AIAvatar(id: "default", name: "Dr. Elena Chen", specialty: "Medical Terminology", thumbnailURL: nil, voiceId: "default"))
            let completed = try await service.awaitCompletion(videoId: response.videoId)

            if let videoURL = completed.videoURL {
                let asset = AVURLAsset(url: videoURL)
                let item = AVPlayerItem(asset: asset)
                let newPlayer = AVPlayer(playerItem: item)
                newPlayer.isMuted = true
                player = newPlayer
                newPlayer.play()
            }

            progress = 1.0
            phase = .playing
            isPlaying = true

            beginSpeaking()

        } catch {
            phase = .error(error.localizedDescription)
        }
    }

    func togglePlayback() {
        if isSpeaking {
            synthesizer.pauseSpeaking(at: .word)
            player?.pause()
            isSpeaking = false
            isPlaying = false
            phase = .ready
        } else if synthesizer.isPaused {
            synthesizer.continueSpeaking()
            player?.play()
            isSpeaking = true
            isPlaying = true
            phase = .playing
        } else {
            beginSpeaking()
            player?.play()
        }
    }

    func nextSentence() {
        guard currentSentenceIndex < sentences.count - 1 else { return }
        synthesizer.stopSpeaking(at: .immediate)
        currentSentenceIndex += 1
        speakCurrentSentence()
    }

    func previousSentence() {
        guard currentSentenceIndex > 0 else {
            synthesizer.stopSpeaking(at: .immediate)
            speakCurrentSentence()
            return
        }
        synthesizer.stopSpeaking(at: .immediate)
        currentSentenceIndex -= 1
        speakCurrentSentence()
    }

    func replay() {
        synthesizer.stopSpeaking(at: .immediate)
        currentSentenceIndex = 0
        player?.seek(to: .zero)
        player?.play()
        beginSpeaking()
    }

    func toggleSpeed() {
        speechRate = (speechRate == .normal) ? .slow : .normal
        if isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
            speakCurrentSentence()
        }
    }

    func stopAll() {
        synthesizer.stopSpeaking(at: .immediate)
        player?.pause()
        player = nil
        isSpeaking = false
        isPlaying = false
    }

    // MARK: - Speech Engine

    private func beginSpeaking() {
        currentSentenceIndex = 0
        isSpeaking = true
        isPlaying = true
        phase = .playing
        speakCurrentSentence()
    }

    private func speakCurrentSentence() {
        guard currentSentenceIndex < sentences.count else {
            isSpeaking = false
            isPlaying = false
            phase = .ready
            return
        }

        let sentence = sentences[currentSentenceIndex]
        let utterance = AVSpeechUtterance(string: sentence)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = speechRate.value
        utterance.pitchMultiplier = 1.05
        utterance.preUtteranceDelay = 0.2
        utterance.postUtteranceDelay = 0.4

        isSpeaking = true
        phase = .playing
        synthesizer.speak(utterance)
    }

    private func splitIntoSentences(_ text: String) -> [String] {
        var results: [String] = []
        text.enumerateSubstrings(in: text.startIndex..., options: .bySentences) { substring, _, _, _ in
            if let s = substring?.trimmingCharacters(in: .whitespacesAndNewlines), !s.isEmpty {
                results.append(s)
            }
        }
        return results.isEmpty ? [text] : results
    }

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try session.setActive(true)
        } catch {
            print("Audio session configuration failed: \(error)")
        }
    }

    // MARK: - AVSpeechSynthesizerDelegate

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            if currentSentenceIndex < sentences.count - 1 {
                currentSentenceIndex += 1
                speakCurrentSentence()
            } else {
                isSpeaking = false
                isPlaying = false
                phase = .ready
            }
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        Task { @MainActor in
            isSpeaking = false
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        Task { @MainActor in
            isSpeaking = true
        }
    }
}

// MARK: - AVPlayerView (muted video backdrop)

struct AVPlayerView: UIViewRepresentable {
    let player: AVPlayer

    func makeUIView(context: Context) -> PlayerUIView {
        let view = PlayerUIView()
        view.player = player
        return view
    }

    func updateUIView(_ uiView: PlayerUIView, context: Context) {
        uiView.player = player
    }

    class PlayerUIView: UIView {
        override class var layerClass: AnyClass { AVPlayerLayer.self }

        var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }

        var player: AVPlayer? {
            get { playerLayer.player }
            set {
                playerLayer.player = newValue
                playerLayer.videoGravity = .resizeAspect
            }
        }

        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = .black
            playerLayer.videoGravity = .resizeAspect
        }

        required init?(coder: NSCoder) { fatalError() }
    }
}
