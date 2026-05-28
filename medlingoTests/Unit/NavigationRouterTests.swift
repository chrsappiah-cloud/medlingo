import Testing
import SwiftUI
@testable import medlingo

@MainActor
struct NavigationRouterTests {
    var sut: NavigationRouter

    init() {
        sut = NavigationRouter()
    }

    @Test func navigateToLearn_appendsDestination() {
        let chapter = Chapter(id: UUID(), number: 1, title: "Test", summary: "", estimatedMinutes: 10, isPremium: false, coverArtURL: nil, accentColorHex: "", prerequisiteIDs: [], unlockRule: .free)
        sut.navigateToLearn(.stageDetail(chapter: chapter, colorIndex: 0))

        #expect(sut.learnPath.count == 1)
    }

    @Test func navigateToPractice_appendsDestination() {
        sut.navigateToPractice(.flashcards(chapterID: UUID()))

        #expect(sut.practicePath.count == 1)
    }

    @Test func popLearn_whenPathNotEmpty_removesLast() {
        sut.navigateToLearn(.settings)
        sut.navigateToLearn(.messages)

        sut.popLearn()

        #expect(sut.learnPath.count == 1)
    }

    @Test func popLearn_whenPathEmpty_doesNothing() {
        sut.popLearn()

        #expect(sut.learnPath.count == 0)
    }

    @Test func resetAll_clearsAllPaths() {
        sut.navigateToLearn(.settings)
        sut.navigateToPractice(.flashcards(chapterID: UUID()))

        sut.resetAll()

        #expect(sut.learnPath.isEmpty)
        #expect(sut.practicePath.isEmpty)
        #expect(sut.studioPath.isEmpty)
        #expect(sut.collectionPath.isEmpty)
        #expect(sut.sessionsPath.isEmpty)
        #expect(sut.progressPath.isEmpty)
        #expect(sut.accountPath.isEmpty)
    }

    @Test func multipleNavigations_stackedCorrectly() {
        sut.navigateToLearn(.settings)
        sut.navigateToLearn(.messages)
        sut.navigateToLearn(.adminConsole)

        #expect(sut.learnPath.count == 3)
    }

    @Test func destination_equality() {
        let id = UUID()
        let dest1 = NavigationRouter.Destination.flashcards(chapterID: id)
        let dest2 = NavigationRouter.Destination.flashcards(chapterID: id)
        let dest3 = NavigationRouter.Destination.flashcards(chapterID: UUID())

        #expect(dest1 == dest2)
        #expect(dest1 != dest3)
    }

    @Test func destination_hashable() {
        let dest = NavigationRouter.Destination.messages
        let set: Set<NavigationRouter.Destination> = [dest, dest]

        #expect(set.count == 1)
    }

    @Test func resetAll_afterMultipleNavigations_clearsAll() {
        sut.navigateToLearn(.settings)
        sut.navigateToLearn(.messages)
        sut.navigateToPractice(.flashcards(chapterID: UUID()))
        sut.navigateToPractice(.wordBuilder(chapterID: UUID()))

        sut.resetAll()

        #expect(sut.learnPath.isEmpty)
        #expect(sut.practicePath.isEmpty)
    }
}
