import Testing
import Foundation
@testable import medlingo

@MainActor
struct HomeViewModelTests {
    var sut: HomeViewModel

    init() {
        sut = HomeViewModel()
    }

    @Test func init_loads5SampleChapters() {
        #expect(sut.chapters.count == 5)
    }

    @Test func currentStage_returnsChapterWithNumber3() {
        let stage = sut.currentStage
        #expect(stage.number == 3)
        #expect(stage.title == "Skeletal")
    }

    @Test func defaultValues_areSet() {
        #expect(sut.currentStreak == 7)
        #expect(sut.totalXP == 1250)
        #expect(sut.currentStageTitle == "Stage 3: Skeletal System")
        #expect(sut.currentLessonTitle == "Bone Structure & Function")
        #expect(sut.stageProgress == 0.45)
        #expect(sut.hasUpcomingSession == true)
        #expect(sut.termsDueForReview == 12)
        #expect(sut.overallMastery == 0.72)
    }

    @Test func chapters_haveSequentialNumbers() {
        let numbers = sut.chapters.map(\.number).sorted()
        #expect(numbers == [1, 2, 3, 4, 5])
    }

    @Test func currentStage_whenNoChapter3_exists_fallsBackToFirst() {
        let vm = HomeViewModel()
        vm.chapters = [
            Chapter(id: UUID(), number: 10, title: "Ten", summary: "", estimatedMinutes: 10, isPremium: false, coverArtURL: nil, accentColorHex: "", prerequisiteIDs: [], unlockRule: .free),
        ]
        #expect(vm.currentStage.number == 10)
    }

    @Test func currentStage_whenChaptersEmpty_returnsDefault() {
        let vm = HomeViewModel()
        vm.chapters = []
        #expect(vm.currentStage.number == 3)
        #expect(vm.currentStage.title == "Skeletal System")
    }

    @Test func chapters_areNotPremium() {
        for chapter in sut.chapters {
            #expect(chapter.isPremium == false)
        }
    }
}
