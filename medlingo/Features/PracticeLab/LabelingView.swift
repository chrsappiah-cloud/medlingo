import SwiftUI

struct LabelingView: View {
    @State private var labels: [DraggableLabel] = LabelingView.sampleLabels.shuffled()
    @State private var placedLabels: [PlacedLabel] = []
    @State private var score = 0
    @State private var isComplete = false
    @State private var selectedLabel: DraggableLabel?
    @State private var showHint = false
    @State private var incorrectFlash: String?
    @State private var correctFlash: String?

    var body: some View {
        VStack(spacing: 0) {
            scoreHeader
            ScrollView {
                VStack(spacing: AppSpacing.md) {
                    diagramArea
                    labelBank
                    if isComplete { completionView }
                }
                .padding(AppSpacing.md)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.background)
        .navigationTitle("Labeling")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    resetExercise()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .foregroundColor(AppColor.gold)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Score Header

    private var scoreHeader: some View {
        VStack(spacing: AppSpacing.xs) {
            HStack {
                Text(selectedLabel != nil ? "Tap the correct region for:" : "Select a label, then tap its region")
                    .font(AppTypography.subheadline)
                    .foregroundColor(AppColor.textSecondary)
                    .animation(.easeInOut, value: selectedLabel?.id)
                Spacer()
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "star.fill")
                        .foregroundColor(AppColor.gold)
                        .shadow(color: AppColor.gold.opacity(0.4), radius: 3)
                    Text("\(score)/\(LabelingView.sampleLabels.count)")
                        .font(AppTypography.headline)
                        .foregroundColor(AppColor.gold)
                }
            }

            if let selected = selectedLabel {
                HStack(spacing: AppSpacing.sm) {
                    Text(selected.text)
                        .font(AppTypography.title3)
                        .foregroundColor(AppColor.diamond)
                        .shadow(color: AppColor.diamond.opacity(0.3), radius: 2)

                    Button {
                        Task {
                            await PronunciationService.shared.pronounce(term: selected.text)
                        }
                    } label: {
                        Image(systemName: "speaker.wave.2.fill")
                            .foregroundColor(AppColor.gold)
                    }
                }
                .padding(.vertical, AppSpacing.xs)
                .transition(.scale.combined(with: .opacity))
            }

            ProgressView(value: Double(placedLabels.count), total: Double(LabelingView.sampleLabels.count))
                .tint(AppColor.emerald)
                .scaleEffect(y: 1.5)
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
        .background(AppColor.surface)
        .animation(.spring(duration: 0.3), value: selectedLabel?.id)
    }

    // MARK: - Diagram Area

    private var diagramArea: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height: CGFloat = 420

            ZStack {
                RoundedRectangle(cornerRadius: AppRadius.xl)
                    .fill(
                        LinearGradient(
                            colors: [AppColor.surface, AppColor.surfaceElevated.opacity(0.5)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.xl)
                            .stroke(AppColor.diamond.opacity(0.15), lineWidth: 1)
                    )

                bodyDiagram(in: CGSize(width: width, height: height))

                ForEach(scaledTargets(in: CGSize(width: width, height: height))) { target in
                    dropZoneButton(for: target)
                }
            }
            .frame(height: height)
        }
        .frame(height: 420)
    }

    @ViewBuilder
    private func bodyDiagram(in size: CGSize) -> some View {
        let centerX = size.width / 2

        ZStack {
            // Head
            Circle()
                .stroke(regionColor(for: "head"), lineWidth: 2)
                .frame(width: 50, height: 50)
                .position(x: centerX, y: 50)

            // Neck
            RoundedRectangle(cornerRadius: 4)
                .stroke(AppColor.textTertiary.opacity(0.4), lineWidth: 1.5)
                .frame(width: 16, height: 20)
                .position(x: centerX, y: 85)

            // Torso (chest)
            RoundedRectangle(cornerRadius: 12)
                .stroke(regionColor(for: "chest"), lineWidth: 2)
                .frame(width: 80, height: 80)
                .position(x: centerX, y: 140)

            // Abdomen
            RoundedRectangle(cornerRadius: 10)
                .stroke(regionColor(for: "abdomen"), lineWidth: 2)
                .frame(width: 70, height: 60)
                .position(x: centerX, y: 220)

            // Left arm
            Capsule()
                .stroke(regionColor(for: "arm"), lineWidth: 2)
                .frame(width: 24, height: 100)
                .rotationEffect(.degrees(-10))
                .position(x: centerX - 65, y: 155)

            // Right arm
            Capsule()
                .stroke(AppColor.textTertiary.opacity(0.4), lineWidth: 1.5)
                .frame(width: 24, height: 100)
                .rotationEffect(.degrees(10))
                .position(x: centerX + 65, y: 155)

            // Left leg
            Capsule()
                .stroke(regionColor(for: "leg"), lineWidth: 2)
                .frame(width: 28, height: 130)
                .rotationEffect(.degrees(-3))
                .position(x: centerX - 22, y: 325)

            // Right leg
            Capsule()
                .stroke(AppColor.textTertiary.opacity(0.4), lineWidth: 1.5)
                .frame(width: 28, height: 130)
                .rotationEffect(.degrees(3))
                .position(x: centerX + 22, y: 325)

            // Pelvis
            Ellipse()
                .stroke(AppColor.textTertiary.opacity(0.4), lineWidth: 1.5)
                .frame(width: 80, height: 30)
                .position(x: centerX, y: 260)

            // Labels for placed items
            ForEach(placedLabels) { placed in
                let target = scaledTargets(in: size).first { $0.id == placed.targetID }
                if let target {
                    placedLabelView(placed, at: target.labelPosition)
                }
            }
        }
    }

    private func placedLabelView(_ placed: PlacedLabel, at position: CGPoint) -> some View {
        HStack(spacing: 4) {
            Image(systemName: placed.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 10))
            Text(placed.label.text)
                .font(.system(size: 11, weight: .semibold))
        }
        .foregroundColor(placed.isCorrect ? AppColor.emerald : AppColor.error)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            (placed.isCorrect ? AppColor.emerald : AppColor.error).opacity(0.15)
        )
        .clipShape(Capsule())
        .position(position)
        .transition(.scale.combined(with: .opacity))
    }

    private func regionColor(for targetID: String) -> Color {
        if correctFlash == targetID { return AppColor.emerald }
        if incorrectFlash == targetID { return AppColor.error }
        if placedLabels.contains(where: { $0.targetID == targetID && $0.isCorrect }) {
            return AppColor.emerald.opacity(0.6)
        }
        if placedLabels.contains(where: { $0.targetID == targetID && !$0.isCorrect }) {
            return AppColor.error.opacity(0.5)
        }
        if selectedLabel != nil { return AppColor.diamond.opacity(0.8) }
        return AppColor.textTertiary.opacity(0.4)
    }

    private func dropZoneButton(for target: ScaledDropTarget) -> some View {
        let alreadyPlaced = placedLabels.contains { $0.targetID == target.id }

        return Button {
            guard !alreadyPlaced, let label = selectedLabel else { return }
            placeLabel(label, on: target)
        } label: {
            Circle()
                .fill(
                    alreadyPlaced
                        ? Color.clear
                        : (selectedLabel != nil ? AppColor.diamond.opacity(0.08) : Color.clear)
                )
                .frame(width: 60, height: 60)
                .overlay(
                    Circle()
                        .stroke(
                            alreadyPlaced
                                ? Color.clear
                                : (selectedLabel != nil ? AppColor.diamond.opacity(0.5) : AppColor.textTertiary.opacity(0.2)),
                            style: StrokeStyle(lineWidth: selectedLabel != nil ? 2.5 : 1.5, dash: alreadyPlaced ? [] : [6])
                        )
                )
                .overlay(
                    Group {
                        if !alreadyPlaced && selectedLabel != nil {
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppColor.diamond.opacity(0.6))
                        }
                    }
                )
                .scaleEffect(selectedLabel != nil && !alreadyPlaced ? 1.1 : 1.0)
                .animation(.spring(duration: 0.3), value: selectedLabel?.id)
        }
        .disabled(alreadyPlaced)
        .position(target.position)
    }

    // MARK: - Label Bank

    private var labelBank: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Text("LABELS")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .tracking(1.5)
                    .foregroundColor(AppColor.textTertiary)
                Spacer()
                if showHint, let selected = selectedLabel {
                    Text("Hint: \(selected.hint)")
                        .font(AppTypography.caption1)
                        .foregroundColor(AppColor.gold)
                        .transition(.opacity)
                }
                if selectedLabel != nil && !showHint {
                    Button("Hint") { withAnimation { showHint = true } }
                        .font(AppTypography.caption1)
                        .foregroundColor(AppColor.gold.opacity(0.7))
                }
            }

            if labels.isEmpty {
                Text("All labels placed!")
                    .font(AppTypography.subheadline)
                    .foregroundColor(AppColor.textTertiary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, AppSpacing.md)
            } else {
                FlowLayout(spacing: AppSpacing.xs) {
                    ForEach(labels) { label in
                        labelChip(label)
                    }
                }
            }
        }
        .padding(AppSpacing.md)
        .background(AppColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .stroke(selectedLabel != nil ? AppColor.diamond.opacity(0.15) : Color.clear, lineWidth: 1)
        )
    }

    private func labelChip(_ label: DraggableLabel) -> some View {
        let isSelected = selectedLabel?.id == label.id

        return Button {
            withAnimation(.spring(duration: 0.2)) {
                if selectedLabel?.id == label.id {
                    selectedLabel = nil
                    showHint = false
                } else {
                    selectedLabel = label
                    showHint = false
                }
            }
        } label: {
            HStack(spacing: AppSpacing.xxs) {
                Text(label.text)
                    .font(AppTypography.headline)
                    .foregroundColor(isSelected ? AppColor.background : AppColor.textPrimary)
            }
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, 10)
            .background(
                isSelected
                    ? AnyShapeStyle(AppColor.goldGradient)
                    : AnyShapeStyle(AppColor.surfaceElevated)
            )
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .stroke(isSelected ? AppColor.gold : AppColor.gold.opacity(0.2), lineWidth: isSelected ? 2 : 1)
            )
            .shadow(color: isSelected ? AppColor.gold.opacity(0.3) : .clear, radius: 6)
            .scaleEffect(isSelected ? 1.05 : 1.0)
        }
        .animation(.spring(duration: 0.2), value: isSelected)
    }

    // MARK: - Completion View

    private var completionView: some View {
        VStack(spacing: AppSpacing.md) {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: score == LabelingView.sampleLabels.count ? "trophy.fill" : "checkmark.seal.fill")
                    .font(.title)
                    .foregroundColor(AppColor.gold)
                    .shadow(color: AppColor.gold.opacity(0.5), radius: 6)

                VStack(alignment: .leading, spacing: 2) {
                    Text(score == LabelingView.sampleLabels.count ? "Perfect Score!" : "Exercise Complete")
                        .font(AppTypography.title3)
                        .foregroundColor(AppColor.textPrimary)
                    Text("\(score) of \(LabelingView.sampleLabels.count) correct")
                        .font(AppTypography.subheadline)
                        .foregroundColor(AppColor.textSecondary)
                }
                Spacer()
            }

            HStack(spacing: AppSpacing.sm) {
                SecondaryButton(title: "Try Again") {
                    resetExercise()
                }
                PrimaryButton(title: "Continue") {
                    AnalyticsService.shared.track(.exerciseCompleted(type: "labeling", chapterID: UUID(), score: Double(score) / Double(LabelingView.sampleLabels.count)))
                }
            }
        }
        .padding(AppSpacing.md)
        .background(AppColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .stroke(AppColor.gold.opacity(0.2), lineWidth: 1)
        )
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    // MARK: - Logic

    private func placeLabel(_ label: DraggableLabel, on target: ScaledDropTarget) {
        let isCorrect = label.correctTargetID == target.id

        withAnimation(.spring(duration: 0.3)) {
            labels.removeAll { $0.id == label.id }
            if isCorrect {
                score += 1
                correctFlash = target.id
            } else {
                incorrectFlash = target.id
            }
            placedLabels.append(PlacedLabel(
                label: label,
                targetID: target.id,
                position: target.position,
                isCorrect: isCorrect
            ))
            selectedLabel = nil
            showHint = false
            if labels.isEmpty { isComplete = true }
        }

        Task {
            try? await Task.sleep(for: .seconds(0.6))
            await MainActor.run {
                withAnimation { correctFlash = nil; incorrectFlash = nil }
            }
        }
    }

    private func resetExercise() {
        withAnimation(.spring(duration: 0.3)) {
            labels = LabelingView.sampleLabels.shuffled()
            placedLabels = []
            score = 0
            isComplete = false
            selectedLabel = nil
            showHint = false
        }
    }

    // MARK: - Targets

    private func scaledTargets(in size: CGSize) -> [ScaledDropTarget] {
        let cx = size.width / 2
        return [
            ScaledDropTarget(id: "head", position: CGPoint(x: cx, y: 50), labelPosition: CGPoint(x: cx + 55, y: 50)),
            ScaledDropTarget(id: "chest", position: CGPoint(x: cx, y: 140), labelPosition: CGPoint(x: cx + 65, y: 140)),
            ScaledDropTarget(id: "abdomen", position: CGPoint(x: cx, y: 220), labelPosition: CGPoint(x: cx + 60, y: 220)),
            ScaledDropTarget(id: "arm", position: CGPoint(x: cx - 65, y: 155), labelPosition: CGPoint(x: cx - 120, y: 155)),
            ScaledDropTarget(id: "leg", position: CGPoint(x: cx - 22, y: 325), labelPosition: CGPoint(x: cx - 75, y: 325)),
        ]
    }

    // MARK: - Sample Data

    static let sampleLabels: [DraggableLabel] = [
        DraggableLabel(text: "Cranium", correctTargetID: "head", hint: "Upper body, houses the brain"),
        DraggableLabel(text: "Thorax", correctTargetID: "chest", hint: "Contains the heart and lungs"),
        DraggableLabel(text: "Abdomen", correctTargetID: "abdomen", hint: "Below the diaphragm, above pelvis"),
        DraggableLabel(text: "Brachium", correctTargetID: "arm", hint: "Upper limb, between shoulder and elbow"),
        DraggableLabel(text: "Femur", correctTargetID: "leg", hint: "Largest bone, in the thigh"),
    ]
}

// MARK: - Supporting Types

struct DraggableLabel: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let correctTargetID: String
    let hint: String

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: DraggableLabel, rhs: DraggableLabel) -> Bool {
        lhs.id == rhs.id
    }
}

struct ScaledDropTarget: Identifiable {
    let id: String
    let position: CGPoint
    let labelPosition: CGPoint
}

struct PlacedLabel: Identifiable {
    let id = UUID()
    let label: DraggableLabel
    let targetID: String
    let position: CGPoint
    let isCorrect: Bool
}

#Preview {
    NavigationStack {
        LabelingView()
    }
}
