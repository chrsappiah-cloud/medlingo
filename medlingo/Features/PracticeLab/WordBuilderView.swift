import SwiftUI

struct WordBuilderView: View {
    @State private var selectedParts: [WordPart] = []
    @State private var availableParts: [WordPart] = WordBuilderView.sampleParts
    @State private var showResult = false
    @State private var isCorrect = false

    static let sampleParts: [WordPart] = [
        WordPart(value: "oste", type: .root, meaning: "bone"),
        WordPart(value: "arthr", type: .root, meaning: "joint"),
        WordPart(value: "cardi", type: .root, meaning: "heart"),
        WordPart(value: "o", type: .combiningForm, meaning: "combining vowel"),
        WordPart(value: "-itis", type: .suffix, meaning: "inflammation"),
        WordPart(value: "-ology", type: .suffix, meaning: "study of"),
        WordPart(value: "-pathy", type: .suffix, meaning: "disease"),
        WordPart(value: "peri-", type: .prefix, meaning: "around"),
    ]

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            promptSection
            buildArea
            availablePartsSection
            Spacer()
            actionButtons
        }
        .padding(AppSpacing.md)
        .background(AppColor.background)
        .navigationTitle("Word Builder")
        .sheet(isPresented: $showResult) {
            resultView
        }
    }

    private var promptSection: some View {
        AppCard {
            VStack(spacing: AppSpacing.sm) {
                Text("Build the term for:")
                    .font(AppTypography.subheadline)
                    .foregroundColor(AppColor.textSecondary)
                Text("Inflammation of a joint")
                    .font(AppTypography.title2)
                    .foregroundColor(AppColor.textPrimary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var buildArea: some View {
        VStack(spacing: AppSpacing.sm) {
            Text("Your Term")
                .font(AppTypography.caption1)
                .foregroundColor(AppColor.textTertiary)

            HStack(spacing: AppSpacing.xxs) {
                if selectedParts.isEmpty {
                    Text("Tap parts below to build")
                        .font(AppTypography.body)
                        .foregroundColor(AppColor.textTertiary)
                } else {
                    ForEach(Array(selectedParts.enumerated()), id: \.offset) { _, part in
                        WordPartChip(part: part, isSelected: true) {
                            withAnimation(.spring(duration: 0.3)) {
                                selectedParts.removeAll { $0 == part }
                                availableParts.append(part)
                            }
                        }
                    }
                }
            }
            .frame(minHeight: 48)
            .frame(maxWidth: .infinity)
            .padding(AppSpacing.md)
            .background(AppColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .strokeBorder(AppColor.primary.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [6]))
            )

            if !selectedParts.isEmpty {
                Text(selectedParts.map(\.value).joined())
                    .font(AppTypography.termDisplay)
                    .foregroundColor(AppColor.primary)
            }
        }
    }

    private var availablePartsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Available Parts")
                .font(AppTypography.caption1)
                .foregroundColor(AppColor.textTertiary)

            FlowLayout(spacing: AppSpacing.xs) {
                ForEach(Array(availableParts.enumerated()), id: \.offset) { _, part in
                    WordPartChip(part: part, isSelected: false) {
                        withAnimation(.spring(duration: 0.3)) {
                            availableParts.removeAll { $0 == part }
                            selectedParts.append(part)
                        }
                    }
                }
            }
        }
    }

    private var actionButtons: some View {
        HStack(spacing: AppSpacing.md) {
            SecondaryButton(title: "Clear") {
                withAnimation {
                    availableParts.append(contentsOf: selectedParts)
                    selectedParts.removeAll()
                }
            }
            PrimaryButton(title: "Check") {
                let answer = selectedParts.map(\.value).joined()
                isCorrect = answer == "arthr" + "o" + "-itis" || answer == "arthritis"
                showResult = true
            }
        }
    }

    private var resultView: some View {
        VStack(spacing: AppSpacing.lg) {
            Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(isCorrect ? AppColor.success : AppColor.error)

            Text(isCorrect ? "Correct!" : "Not quite")
                .font(AppTypography.title1)

            VStack(spacing: AppSpacing.xs) {
                Text("arthritis")
                    .font(AppTypography.termDisplay)
                    .foregroundColor(AppColor.primary)
                Text("arthr (joint) + -itis (inflammation)")
                    .font(AppTypography.body)
                    .foregroundColor(AppColor.textSecondary)
            }

            PrimaryButton(title: "Next Term") {
                showResult = false
                withAnimation {
                    availableParts.append(contentsOf: selectedParts)
                    selectedParts.removeAll()
                }
            }
            .padding(.top, AppSpacing.md)
        }
        .padding(AppSpacing.lg)
        .presentationDetents([.medium])
    }
}

struct WordPartChip: View {
    let part: WordPart
    let isSelected: Bool
    let action: () -> Void

    private var chipColor: Color {
        switch part.type {
        case .prefix: return .blue
        case .root: return .purple
        case .suffix: return .orange
        case .combiningForm: return .teal
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text(part.value)
                    .font(AppTypography.headline)
                    .foregroundColor(isSelected ? .white : chipColor)
                Text(part.meaning)
                    .font(.system(size: 9))
                    .foregroundColor(isSelected ? .white.opacity(0.8) : chipColor.opacity(0.7))
            }
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, AppSpacing.xs)
            .background(isSelected ? chipColor : chipColor.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm))
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        for (index, subview) in subviews.enumerated() {
            let point = CGPoint(
                x: bounds.minX + result.positions[index].x,
                y: bounds.minY + result.positions[index].y
            )
            subview.place(at: point, anchor: .topLeading, proposal: .unspecified)
        }
    }

    private func computeLayout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth, currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            maxX = max(maxX, currentX)
        }

        return (CGSize(width: maxX, height: currentY + lineHeight), positions)
    }
}

#Preview {
    NavigationStack {
        WordBuilderView()
    }
}
