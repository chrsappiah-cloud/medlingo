import SwiftUI

@MainActor
@Observable
final class NavigationRouter {
    var learnPath = NavigationPath()
    var practicePath = NavigationPath()
    var sessionsPath = NavigationPath()
    var progressPath = NavigationPath()
    var accountPath = NavigationPath()

    enum Destination: Hashable {
        case stageDetail(chapter: Chapter, colorIndex: Int)
        case lessonPlayer(lessonID: UUID, chapterID: UUID)
        case exercise(exerciseID: UUID)
        case wordBuilder(chapterID: UUID)
        case flashcards(chapterID: UUID)
        case labeling(chapterID: UUID)
        case quiz(chapterID: UUID)
        case caseStudy(chapterID: UUID)
        case tutorProfile(tutorID: UUID)
        case bookSession(sessionID: UUID)
        case sessionRoom(sessionID: UUID)
        case messages
        case subscription
        case settings
        case adminConsole
    }

    func navigateToLearn(_ destination: Destination) {
        learnPath.append(destination)
    }

    func navigateToPractice(_ destination: Destination) {
        practicePath.append(destination)
    }

    func popLearn() {
        if !learnPath.isEmpty {
            learnPath.removeLast()
        }
    }

    func resetAll() {
        learnPath = NavigationPath()
        practicePath = NavigationPath()
        sessionsPath = NavigationPath()
        progressPath = NavigationPath()
        accountPath = NavigationPath()
    }
}
