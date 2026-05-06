import Foundation

struct Exercise: Identifiable, Codable, Hashable {
    let id: UUID
    let chapterID: UUID
    let lessonID: UUID?
    let type: ExerciseType
    let title: String
    let instructions: String?
    let difficulty: Difficulty
    let xpReward: Int
    let questions: [QuestionItem]

    enum ExerciseType: String, Codable, Hashable {
        case multipleChoice = "mcq"
        case termBuilder = "term_build"
        case labeling
        case flashcard
        case caseStudy = "case_study"
        case fillInTheBlank = "fill_blank"
        case abbreviation
        case matching
    }

    enum Difficulty: String, Codable, Hashable {
        case beginner
        case intermediate
        case advanced
    }
}

struct QuestionItem: Identifiable, Codable, Hashable {
    let id: UUID
    let prompt: String
    let options: [String]?
    let correctAnswer: String
    let explanation: String?
    let mediaURL: URL?
    let wordParts: [WordPart]?
}

struct WordPart: Codable, Hashable {
    let value: String
    let type: WordPartType
    let meaning: String

    enum WordPartType: String, Codable, Hashable {
        case prefix
        case root
        case suffix
        case combiningForm = "combining_form"
    }
}
