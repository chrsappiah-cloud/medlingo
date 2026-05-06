import SwiftUI
import AVFoundation

struct LessonPlayerView: View {
    let lesson: Lesson
    let stageColor: Color

    @State private var currentSection = 0
    @State private var isCompleted = false
    @State private var showPronunciation = false
    @Environment(\.dismiss) private var dismiss

    private let pronunciationService = PronunciationService.shared

    var body: some View {
        VStack(spacing: 0) {
            progressBar
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    lessonHeader
                    lessonContent
                    mediaSection
                    keyTermsSection
                }
                .padding(AppSpacing.md)
                .padding(.bottom, AppSpacing.xxl)
            }
            bottomBar
        }
        .background(AppColor.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .preferredColorScheme(.dark)
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(stageColor.opacity(0.15))
                Rectangle()
                    .fill(stageColor)
                    .frame(width: geo.size.width * Double(currentSection + 1) / 6.0)
                    .animation(.spring(duration: 0.4), value: currentSection)
            }
        }
        .frame(height: 4)
    }

    private var lessonHeader: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Text("LESSON \(lesson.orderIndex + 1)")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .tracking(1.5)
                    .foregroundColor(stageColor)
                Spacer()
                Label("\(lesson.estimatedMinutes) min", systemImage: "clock")
                    .font(AppTypography.caption1)
                    .foregroundColor(AppColor.textTertiary)
            }
            Text(lesson.title)
                .font(AppTypography.title1)
                .foregroundColor(AppColor.textPrimary)
        }
    }

    private var lessonContent: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text(lesson.content)
                .font(AppTypography.body)
                .foregroundColor(AppColor.textSecondary)
                .lineSpacing(6)
        }
    }

    private var mediaSection: some View {
        Group {
            if !lesson.mediaAssets.isEmpty {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    SectionHeader(title: "Media")
                    ForEach(lesson.mediaAssets) { asset in
                        MediaAssetRow(asset: asset)
                    }
                }
            }
        }
    }

    private var keyTermsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(title: "Key Terms")

            VStack(spacing: AppSpacing.xs) {
                PronounceableTermRow(term: "oste/o", meaning: "bone", color: stageColor)
                PronounceableTermRow(term: "arthr/o", meaning: "joint", color: stageColor)
                PronounceableTermRow(term: "-itis", meaning: "inflammation", color: stageColor)
                PronounceableTermRow(term: "-ectomy", meaning: "surgical removal", color: stageColor)
            }
        }
    }

    private var bottomBar: some View {
        HStack(spacing: AppSpacing.md) {
            if currentSection > 0 {
                SecondaryButton(title: "Previous") {
                    withAnimation { currentSection -= 1 }
                }
            }
            PrimaryButton(title: currentSection >= 5 ? "Complete" : "Next") {
                if currentSection >= 5 {
                    isCompleted = true
                    AnalyticsService.shared.track(.lessonCompleted(chapterID: lesson.chapterID, lessonID: lesson.id, durationSeconds: lesson.estimatedMinutes * 60))
                    dismiss()
                } else {
                    withAnimation { currentSection += 1 }
                }
            }
        }
        .padding(AppSpacing.md)
        .background(AppColor.surface)
    }
}

struct PronounceableTermRow: View {
    let term: String
    let meaning: String
    let color: Color

    @State private var isPlaying = false

    var body: some View {
        HStack {
            Button {
                isPlaying = true
                Task {
                    await PronunciationService.shared.pronounce(term: term)
                    isPlaying = false
                }
            } label: {
                Image(systemName: isPlaying ? "speaker.wave.3.fill" : "speaker.wave.2")
                    .foregroundColor(color)
                    .font(.body)
                    .frame(width: 28)
            }

            Text(term)
                .font(AppTypography.termDisplay)
                .foregroundColor(AppColor.diamond)

            Spacer()

            Text(meaning)
                .font(AppTypography.body)
                .foregroundColor(AppColor.textSecondary)
        }
        .padding(.vertical, AppSpacing.xs)
    }
}

struct MediaAssetRow: View {
    let asset: MediaAsset

    var body: some View {
        HStack {
            Image(systemName: iconForType(asset.type))
                .foregroundColor(AppColor.gold)
                .frame(width: 28)
            VStack(alignment: .leading) {
                Text(asset.caption ?? "Media")
                    .font(AppTypography.subheadline)
                    .foregroundColor(AppColor.textPrimary)
                Text(asset.type.rawValue.capitalized)
                    .font(AppTypography.caption2)
                    .foregroundColor(AppColor.textTertiary)
            }
            Spacer()
            Image(systemName: "play.circle.fill")
                .foregroundColor(AppColor.diamond)
        }
        .padding(AppSpacing.sm)
        .background(AppColor.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm))
    }

    private func iconForType(_ type: MediaAsset.MediaType) -> String {
        switch type {
        case .image: return "photo"
        case .diagram: return "square.on.square"
        case .video: return "play.rectangle"
        case .pdf: return "doc.text"
        case .audio: return "waveform"
        }
    }
}
