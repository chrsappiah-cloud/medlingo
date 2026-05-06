import SwiftUI

struct FlashcardsView: View {
    @State private var cards: [FlashcardItem] = FlashcardsView.sampleCards
    @State private var currentIndex = 0
    @State private var isFlipped = false
    @State private var offset: CGSize = .zero
    @State private var knownCount = 0
    @State private var unknownCount = 0

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            progressHeader
            cardStack
            controlButtons
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.background)
        .navigationTitle("Flashcards")
        .toolbarColorScheme(.dark, for: .navigationBar)
        .preferredColorScheme(.dark)
    }

    // MARK: - Progress Header

    private var progressHeader: some View {
        HStack {
            Label("\(unknownCount)", systemImage: "xmark.circle.fill")
                .font(AppTypography.headline)
                .foregroundColor(AppColor.error)

            Spacer()

            Text("\(currentIndex + 1) of \(cards.count)")
                .font(AppTypography.subheadline)
                .foregroundColor(AppColor.textSecondary)

            Spacer()

            Label("\(knownCount)", systemImage: "checkmark.circle.fill")
                .font(AppTypography.headline)
                .foregroundColor(AppColor.emerald)
        }
        .padding(.horizontal, AppSpacing.md)
    }

    // MARK: - Card Stack

    private var cardStack: some View {
        ZStack {
            if currentIndex < cards.count {
                cardView(for: cards[currentIndex])
                    .offset(offset)
                    .rotationEffect(.degrees(Double(offset.width) / 20))
                    .gesture(dragGesture)
                    .animation(.spring(duration: 0.4), value: offset)
            } else {
                completionView
            }
        }
        .frame(maxHeight: .infinity)
    }

    private func cardView(for card: FlashcardItem) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppRadius.xl)
                .fill(AppColor.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.xl)
                        .stroke(swipeIndicatorColor, lineWidth: 2)
                )
                .shadow(color: .black.opacity(0.4), radius: 16, x: 0, y: 8)

            VStack(spacing: AppSpacing.lg) {
                Text(isFlipped ? "Definition" : "Term")
                    .font(AppTypography.caption1)
                    .foregroundColor(AppColor.textTertiary)
                    .textCase(.uppercase)

                Text(isFlipped ? card.meaning : card.term)
                    .font(isFlipped ? AppTypography.title3 : AppTypography.termDisplay)
                    .foregroundColor(AppColor.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.lg)

                if !isFlipped {
                    speakerButton(for: card.term)
                }

                Text("Tap to flip")
                    .font(AppTypography.caption1)
                    .foregroundColor(AppColor.textTertiary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 400)
        .padding(.horizontal, AppSpacing.md)
        .onTapGesture {
            withAnimation(.spring(duration: 0.3)) {
                isFlipped.toggle()
            }
        }
    }

    private func speakerButton(for term: String) -> some View {
        Button {
            Task {
                await PronunciationService.shared.pronounce(term: term)
            }
        } label: {
            Image(systemName: "speaker.wave.2.fill")
                .font(.title2)
                .foregroundColor(AppColor.gold)
                .padding(AppSpacing.sm)
                .background(AppColor.surfaceElevated)
                .clipShape(Circle())
        }
    }

    private var swipeIndicatorColor: Color {
        if offset.width > 30 { return AppColor.emerald.opacity(0.6) }
        if offset.width < -30 { return AppColor.error.opacity(0.6) }
        return Color.white.opacity(0.06)
    }

    private var completionView: some View {
        VStack(spacing: AppSpacing.lg) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 64))
                .foregroundColor(AppColor.gold)
                .shadow(color: AppColor.gold.opacity(0.4), radius: 8)

            Text("Deck Complete!")
                .font(AppTypography.title1)
                .foregroundColor(AppColor.textPrimary)

            HStack(spacing: AppSpacing.xl) {
                StatTile(title: "Known", value: "\(knownCount)", icon: "checkmark.circle.fill", color: AppColor.emerald)
                StatTile(title: "Review", value: "\(unknownCount)", icon: "arrow.counterclockwise", color: AppColor.error)
            }

            PrimaryButton(title: "Restart Deck") {
                resetDeck()
            }
            .padding(.top, AppSpacing.md)
        }
        .padding(AppSpacing.lg)
    }

    // MARK: - Controls

    private var controlButtons: some View {
        HStack(spacing: AppSpacing.xl) {
            Button {
                swipeLeft()
            } label: {
                Image(systemName: "xmark")
                    .font(.title2.bold())
                    .foregroundColor(AppColor.error)
                    .frame(width: 56, height: 56)
                    .background(AppColor.error.opacity(0.15))
                    .clipShape(Circle())
            }

            Button {
                swipeRight()
            } label: {
                Image(systemName: "checkmark")
                    .font(.title2.bold())
                    .foregroundColor(AppColor.emerald)
                    .frame(width: 56, height: 56)
                    .background(AppColor.emerald.opacity(0.15))
                    .clipShape(Circle())
            }
        }
        .opacity(currentIndex < cards.count ? 1 : 0)
    }

    // MARK: - Gestures

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                offset = value.translation
            }
            .onEnded { value in
                if value.translation.width > 100 {
                    swipeRight()
                } else if value.translation.width < -100 {
                    swipeLeft()
                } else {
                    offset = .zero
                }
            }
    }

    // MARK: - Actions

    private func swipeRight() {
        withAnimation(.easeOut(duration: 0.3)) {
            offset = CGSize(width: 500, height: 0)
        }
        knownCount += 1
        advanceCard()
    }

    private func swipeLeft() {
        withAnimation(.easeOut(duration: 0.3)) {
            offset = CGSize(width: -500, height: 0)
        }
        unknownCount += 1
        advanceCard()
    }

    private func advanceCard() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            currentIndex += 1
            offset = .zero
            isFlipped = false
        }
    }

    private func resetDeck() {
        currentIndex = 0
        knownCount = 0
        unknownCount = 0
        isFlipped = false
        offset = .zero
    }

    // MARK: - Sample Data

    static let sampleCards: [FlashcardItem] = [
        FlashcardItem(term: "Osteo-", meaning: "Bone; relating to bone tissue"),
        FlashcardItem(term: "Cardi/o", meaning: "Heart; relating to the heart"),
        FlashcardItem(term: "-ectomy", meaning: "Surgical removal of"),
        FlashcardItem(term: "Nephro-", meaning: "Kidney; relating to the kidneys"),
        FlashcardItem(term: "-itis", meaning: "Inflammation of"),
        FlashcardItem(term: "Hepat/o", meaning: "Liver; relating to the liver"),
        FlashcardItem(term: "-plasty", meaning: "Surgical repair or reconstruction"),
        FlashcardItem(term: "Derm/o", meaning: "Skin; relating to the skin"),
    ]
}

struct FlashcardItem: Identifiable, Hashable {
    let id = UUID()
    let term: String
    let meaning: String
}

#Preview {
    NavigationStack {
        FlashcardsView()
    }
}
