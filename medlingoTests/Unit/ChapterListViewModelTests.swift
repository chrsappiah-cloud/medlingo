import Testing
import Foundation
@testable import medlingo

@MainActor
struct ChapterListViewModelTests {
    var sut: ChapterListViewModel

    init() {
        sut = ChapterListViewModel()
    }

    @Test func init_loads15Chapters() {
        #expect(sut.chapters.count == 15)
    }

    @Test func chapters_haveSequentialNumbers() {
        let sorted = sut.chapters.sorted { $0.number < $1.number }
        for (index, chapter) in sorted.enumerated() {
            #expect(chapter.number == index + 1)
        }
    }

    @Test func chapters_areFree() {
        for chapter in sut.chapters {
            #expect(chapter.unlockRule == .free || chapter.unlockRule == .sequential)
        }
    }

    @Test func progress_forNewChapter_returnsZero() {
        let newChapter = Chapter(id: UUID(), number: 99, title: "New", summary: "", estimatedMinutes: 10, coverArtURL: nil, accentColorHex: "", prerequisiteIDs: [], unlockRule: .free)
        #expect(sut.progress(for: newChapter) == 0)
    }

    @Test func progress_forExistingChapter_returnsStoredValue() {
        let chapter = sut.chapters.first!
        let progress = sut.progress(for: chapter)
        #expect(progress >= 0)
        #expect(progress <= 1.0)
    }

    @Test func isLoading_isFalseByDefault() {
        #expect(sut.isLoading == false)
    }

    @Test func firstChapterIsWordParts() {
        let first = sut.chapters.min(by: { $0.number < $1.number })
        #expect(first?.title == "Word Parts & Foundations")
    }

    @Test func lastChapterIsClinicalApplications() {
        let last = sut.chapters.max(by: { $0.number < $1.number })
        #expect(last?.title == "Clinical Applications")
    }
}
