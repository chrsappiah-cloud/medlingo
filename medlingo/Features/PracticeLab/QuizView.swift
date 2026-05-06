import SwiftUI

struct QuizView: View {
    let exercise: Exercise?

    @State private var questions: [QuizQuestion] = QuizView.sampleQuestions
    @State private var currentIndex = 0
    @State private var selectedAnswer: String?
    @State private var score = 0
    @State private var answers: [(questionID: UUID, answer: String, correct: Bool)] = []
    @State private var timeRemaining = 30
    @State private var isComplete = false
    @State private var showFeedback = false
    @State private var lastAnswerCorrect = false
    @State private var timerActive = true

    init(exercise: Exercise? = nil) {
        self.exercise = exercise
    }

    var body: some View {
        VStack(spacing: 0) {
            if isComplete {
                resultsView
            } else {
                quizContent
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.background)
        .navigationTitle("Quiz")
        .toolbarColorScheme(.dark, for: .navigationBar)
        .preferredColorScheme(.dark)
    }

    // MARK: - Quiz Content

    private var quizContent: some View {
        VStack(spacing: AppSpacing.lg) {
            timerAndProgress
            questionCard
            optionsGrid
            Spacer()
        }
        .padding(AppSpacing.md)
        .task(id: currentIndex) {
            await startTimer()
        }
    }

    private var timerAndProgress: some View {
        HStack {
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: "clock.fill")
                    .foregroundColor(timerColor)
                Text("\(timeRemaining)s")
                    .font(AppTypography.headline)
                    .foregroundColor(timerColor)
                    .monospacedDigit()
            }

            Spacer()

            Text("Q\(currentIndex + 1)/\(questions.count)")
                .font(AppTypography.subheadline)
                .foregroundColor(AppColor.textSecondary)

            Spacer()

            HStack(spacing: AppSpacing.xs) {
                Image(systemName: "star.fill")
                    .foregroundColor(AppColor.gold)
                Text("\(score)")
                    .font(AppTypography.headline)
                    .foregroundColor(AppColor.gold)
            }
        }
    }

    private var timerColor: Color {
        if timeRemaining <= 5 { return AppColor.error }
        if timeRemaining <= 10 { return AppColor.warning }
        return AppColor.textSecondary
    }

    private var questionCard: some View {
        AppCard {
            VStack(spacing: AppSpacing.sm) {
                Text(questions[currentIndex].prompt)
                    .font(AppTypography.title3)
                    .foregroundColor(AppColor.textPrimary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            .padding(.vertical, AppSpacing.lg)
        }
    }

    private var optionsGrid: some View {
        VStack(spacing: AppSpacing.sm) {
            ForEach(questions[currentIndex].options, id: \.self) { option in
                optionButton(option)
            }
        }
    }

    private func optionButton(_ option: String) -> some View {
        Button {
            guard selectedAnswer == nil else { return }
            selectAnswer(option)
        } label: {
            HStack {
                Text(option)
                    .font(AppTypography.quizOption)
                    .foregroundColor(optionTextColor(for: option))
                    .multilineTextAlignment(.leading)
                Spacer()
                if showFeedback && option == questions[currentIndex].correctAnswer {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppColor.emerald)
                } else if showFeedback && option == selectedAnswer && !lastAnswerCorrect {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppColor.error)
                }
            }
            .padding(AppSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(optionBackground(for: option))
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .stroke(optionBorderColor(for: option), lineWidth: 1.5)
            )
        }
        .disabled(selectedAnswer != nil)
    }

    private func optionTextColor(for option: String) -> Color {
        guard showFeedback else { return AppColor.textPrimary }
        if option == questions[currentIndex].correctAnswer { return AppColor.emerald }
        if option == selectedAnswer { return AppColor.error }
        return AppColor.textTertiary
    }

    private func optionBackground(for option: String) -> Color {
        guard showFeedback else { return AppColor.surface }
        if option == questions[currentIndex].correctAnswer { return AppColor.emerald.opacity(0.1) }
        if option == selectedAnswer { return AppColor.error.opacity(0.1) }
        return AppColor.surface.opacity(0.5)
    }

    private func optionBorderColor(for option: String) -> Color {
        guard showFeedback else { return Color.white.opacity(0.06) }
        if option == questions[currentIndex].correctAnswer { return AppColor.emerald.opacity(0.5) }
        if option == selectedAnswer { return AppColor.error.opacity(0.5) }
        return Color.clear
    }

    // MARK: - Results

    private var resultsView: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()

            Image(systemName: scoreIcon)
                .font(.system(size: 72))
                .foregroundColor(scoreColor)
                .shadow(color: scoreColor.opacity(0.4), radius: 12)

            Text(scoreMessage)
                .font(AppTypography.title1)
                .foregroundColor(AppColor.textPrimary)

            Text("\(score) / \(questions.count) correct")
                .font(AppTypography.title3)
                .foregroundColor(AppColor.textSecondary)

            ProgressRing(
                progress: Double(score) / Double(questions.count),
                lineWidth: 12,
                size: 120,
                color: scoreColor
            )
            .overlay(
                Text("\(Int(Double(score) / Double(questions.count) * 100))%")
                    .font(AppTypography.statValue)
                    .foregroundColor(scoreColor)
            )

            Spacer()

            PrimaryButton(title: "Done") {
                submitResults()
            }
            .padding(.horizontal, AppSpacing.lg)
        }
        .padding(AppSpacing.lg)
    }

    private var scoreIcon: String {
        let pct = Double(score) / Double(questions.count)
        if pct >= 0.8 { return "trophy.fill" }
        if pct >= 0.6 { return "hand.thumbsup.fill" }
        return "arrow.counterclockwise.circle.fill"
    }

    private var scoreColor: Color {
        let pct = Double(score) / Double(questions.count)
        if pct >= 0.8 { return AppColor.gold }
        if pct >= 0.6 { return AppColor.emerald }
        return AppColor.error
    }

    private var scoreMessage: String {
        let pct = Double(score) / Double(questions.count)
        if pct >= 0.8 { return "Excellent!" }
        if pct >= 0.6 { return "Good Job!" }
        return "Keep Practicing"
    }

    // MARK: - Logic

    private func startTimer() async {
        timeRemaining = 30
        timerActive = true
        while timeRemaining > 0 && timerActive && !isComplete {
            try? await Task.sleep(for: .seconds(1))
            guard timerActive else { break }
            timeRemaining -= 1
        }
        if timeRemaining == 0 && selectedAnswer == nil && !isComplete {
            selectAnswer("")
        }
    }

    private func selectAnswer(_ answer: String) {
        timerActive = false
        selectedAnswer = answer
        let correct = answer == questions[currentIndex].correctAnswer
        lastAnswerCorrect = correct
        if correct { score += 1 }
        answers.append((
            questionID: questions[currentIndex].id,
            answer: answer,
            correct: correct
        ))
        showFeedback = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            moveToNext()
        }
    }

    private func moveToNext() {
        if currentIndex + 1 < questions.count {
            currentIndex += 1
            selectedAnswer = nil
            showFeedback = false
            lastAnswerCorrect = false
        } else {
            isComplete = true
        }
    }

    private func submitResults() {
        let chapterID = exercise?.chapterID ?? UUID()
        let exerciseID = exercise?.id ?? UUID()
        Task {
            await DataMiddleware.shared.submitAttempt(
                exerciseID: exerciseID,
                chapterID: chapterID,
                answers: answers
            )
        }
    }

    // MARK: - Sample Data

    static let sampleQuestions: [QuizQuestion] = [
        QuizQuestion(prompt: "What does the prefix 'hyper-' mean?", options: ["Above/Excessive", "Below/Under", "Around", "Between"], correctAnswer: "Above/Excessive"),
        QuizQuestion(prompt: "Which suffix means 'inflammation'?", options: ["-osis", "-emia", "-itis", "-ectomy"], correctAnswer: "-itis"),
        QuizQuestion(prompt: "The root 'cardi' refers to which organ?", options: ["Brain", "Lung", "Heart", "Liver"], correctAnswer: "Heart"),
        QuizQuestion(prompt: "What does '-ectomy' mean?", options: ["Study of", "Surgical removal", "Pain", "Condition"], correctAnswer: "Surgical removal"),
        QuizQuestion(prompt: "Which prefix means 'around'?", options: ["Endo-", "Peri-", "Epi-", "Sub-"], correctAnswer: "Peri-"),
    ]
}

struct QuizQuestion: Identifiable, Hashable {
    let id = UUID()
    let prompt: String
    let options: [String]
    let correctAnswer: String
}

#Preview {
    NavigationStack {
        QuizView()
    }
}
