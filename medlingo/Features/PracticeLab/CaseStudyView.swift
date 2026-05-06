import SwiftUI

struct CaseStudyView: View {
    @State private var caseData: ClinicalCase = CaseStudyView.sampleCase
    @State private var mcqAnswers: [UUID: String] = [:]
    @State private var freeTextAnswers: [UUID: String] = [:]
    @State private var isSubmitted = false
    @State private var isSubmitting = false
    @State private var score = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                scenarioSection
                questionsSection
                if isSubmitted {
                    resultsSection
                } else {
                    submitSection
                }
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.top, AppSpacing.md)
            .padding(.bottom, AppSpacing.xxl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.background)
        .navigationTitle("Case Study")
        .toolbarColorScheme(.dark, for: .navigationBar)
        .preferredColorScheme(.dark)
    }

    // MARK: - Scenario

    private var scenarioSection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                HStack {
                    Image(systemName: "doc.text.magnifyingglass")
                        .foregroundColor(AppColor.diamond)
                    Text("Clinical Scenario")
                        .font(AppTypography.headline)
                        .foregroundColor(AppColor.diamond)
                }

                Text(caseData.scenario)
                    .font(AppTypography.body)
                    .foregroundColor(AppColor.textPrimary)
                    .lineSpacing(4)

                if let vitals = caseData.vitals {
                    Divider().background(AppColor.textTertiary)
                    VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                        Text("Vitals")
                            .font(AppTypography.caption1)
                            .foregroundColor(AppColor.textTertiary)
                        Text(vitals)
                            .font(AppTypography.subheadline)
                            .foregroundColor(AppColor.textSecondary)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Questions

    private var questionsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: "Questions")

            ForEach(Array(caseData.questions.enumerated()), id: \.element.id) { index, question in
                questionView(question, number: index + 1)
            }
        }
    }

    @ViewBuilder
    private func questionView(_ question: CaseQuestion, number: Int) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Q\(number). \(question.prompt)")
                .font(AppTypography.headline)
                .foregroundColor(AppColor.textPrimary)

            switch question.type {
            case .mcq:
                mcqOptions(for: question)
            case .freeText:
                freeTextInput(for: question)
            }
        }
        .padding(AppSpacing.md)
        .background(AppColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.md)
                .stroke(questionBorderColor(for: question), lineWidth: 1)
        )
    }

    private func mcqOptions(for question: CaseQuestion) -> some View {
        VStack(spacing: AppSpacing.xs) {
            ForEach(question.options ?? [], id: \.self) { option in
                Button {
                    guard !isSubmitted else { return }
                    mcqAnswers[question.id] = option
                } label: {
                    HStack {
                        Image(systemName: mcqAnswers[question.id] == option ? "circle.inset.filled" : "circle")
                            .foregroundColor(mcqOptionColor(question: question, option: option))
                        Text(option)
                            .font(AppTypography.body)
                            .foregroundColor(AppColor.textPrimary)
                            .multilineTextAlignment(.leading)
                        Spacer()
                        if isSubmitted && option == question.correctAnswer {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(AppColor.emerald)
                        }
                    }
                    .padding(AppSpacing.sm)
                    .background(mcqOptionBackground(question: question, option: option))
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm))
                }
                .disabled(isSubmitted)
            }
        }
    }

    private func mcqOptionColor(question: CaseQuestion, option: String) -> Color {
        guard isSubmitted else {
            return mcqAnswers[question.id] == option ? AppColor.gold : AppColor.textTertiary
        }
        if option == question.correctAnswer { return AppColor.emerald }
        if mcqAnswers[question.id] == option { return AppColor.error }
        return AppColor.textTertiary
    }

    private func mcqOptionBackground(question: CaseQuestion, option: String) -> Color {
        guard isSubmitted else { return AppColor.surfaceElevated }
        if option == question.correctAnswer { return AppColor.emerald.opacity(0.1) }
        if mcqAnswers[question.id] == option { return AppColor.error.opacity(0.1) }
        return AppColor.surfaceElevated.opacity(0.5)
    }

    private func freeTextInput(for question: CaseQuestion) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            TextField("Type your answer...", text: binding(for: question.id), axis: .vertical)
                .font(AppTypography.body)
                .foregroundColor(AppColor.textPrimary)
                .padding(AppSpacing.sm)
                .background(AppColor.surfaceElevated)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm))
                .lineLimit(3...6)
                .disabled(isSubmitted)

            if isSubmitted, let correctAnswer = question.correctAnswer {
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(AppColor.gold)
                    Text("Expected: \(correctAnswer)")
                        .font(AppTypography.caption1)
                        .foregroundColor(AppColor.textSecondary)
                }
            }
        }
    }

    private func questionBorderColor(for question: CaseQuestion) -> Color {
        guard isSubmitted else { return Color.white.opacity(0.06) }
        switch question.type {
        case .mcq:
            if mcqAnswers[question.id] == question.correctAnswer { return AppColor.emerald.opacity(0.4) }
            return AppColor.error.opacity(0.4)
        case .freeText:
            return AppColor.gold.opacity(0.3)
        }
    }

    private func binding(for questionID: UUID) -> Binding<String> {
        Binding(
            get: { freeTextAnswers[questionID] ?? "" },
            set: { freeTextAnswers[questionID] = $0 }
        )
    }

    // MARK: - Results

    private var resultsSection: some View {
        AppCard {
            VStack(spacing: AppSpacing.sm) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.largeTitle)
                    .foregroundColor(AppColor.gold)
                Text("Case Submitted")
                    .font(AppTypography.title3)
                    .foregroundColor(AppColor.textPrimary)
                Text("MCQ Score: \(score)/\(caseData.questions.filter { $0.type == .mcq }.count)")
                    .font(AppTypography.subheadline)
                    .foregroundColor(AppColor.textSecondary)
                Text("Free-text answers reviewed above")
                    .font(AppTypography.caption1)
                    .foregroundColor(AppColor.textTertiary)
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Submit

    private var submitSection: some View {
        PrimaryButton(title: "Submit Answers", isLoading: isSubmitting) {
            submitCase()
        }
        .padding(.top, AppSpacing.md)
    }

    private func submitCase() {
        isSubmitting = true
        score = caseData.questions.filter { q in
            q.type == .mcq && mcqAnswers[q.id] == q.correctAnswer
        }.count

        let answers: [(questionID: UUID, answer: String, correct: Bool)] = caseData.questions.compactMap { q in
            switch q.type {
            case .mcq:
                let given = mcqAnswers[q.id] ?? ""
                return (q.id, given, given == q.correctAnswer)
            case .freeText:
                let given = freeTextAnswers[q.id] ?? ""
                return (q.id, given, !given.isEmpty)
            }
        }

        Task {
            await DataMiddleware.shared.submitAttempt(
                exerciseID: UUID(),
                chapterID: UUID(),
                answers: answers
            )
            isSubmitting = false
            isSubmitted = true
        }
    }

    // MARK: - Sample Data

    static let sampleCase = ClinicalCase(
        scenario: "A 55-year-old male presents to the emergency department with sudden onset severe chest pain radiating to the left arm, diaphoresis, and shortness of breath. He has a history of hypertension and hyperlipidemia. He takes lisinopril and atorvastatin daily.",
        vitals: "BP: 160/95 mmHg | HR: 110 bpm | RR: 22 | SpO2: 94% | Temp: 37.1°C",
        questions: [
            CaseQuestion(prompt: "What is the most likely diagnosis?", type: .mcq, options: ["Acute myocardial infarction", "Pulmonary embolism", "Aortic dissection", "Pneumothorax"], correctAnswer: "Acute myocardial infarction"),
            CaseQuestion(prompt: "Break down the term 'myocardial' into its word parts and define each.", type: .freeText, options: nil, correctAnswer: "myo- (muscle) + cardi (heart) + -al (pertaining to) = pertaining to heart muscle"),
            CaseQuestion(prompt: "Which initial diagnostic test is most appropriate?", type: .mcq, options: ["12-lead ECG", "CT Angiography", "Chest X-ray", "Echocardiogram"], correctAnswer: "12-lead ECG"),
            CaseQuestion(prompt: "Define 'diaphoresis' and identify its Greek root.", type: .freeText, options: nil, correctAnswer: "Excessive sweating. From Greek 'dia-' (through) + 'phoresis' (carrying/bearing)"),
        ]
    )
}

// MARK: - Supporting Types

struct ClinicalCase {
    let scenario: String
    let vitals: String?
    let questions: [CaseQuestion]
}

struct CaseQuestion: Identifiable {
    let id = UUID()
    let prompt: String
    let type: CaseQuestionType
    let options: [String]?
    let correctAnswer: String?

    enum CaseQuestionType {
        case mcq
        case freeText
    }
}

#Preview {
    NavigationStack {
        CaseStudyView()
    }
}
