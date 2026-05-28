import Testing
import Foundation
@testable import medlingo

struct AnalyticsServiceBehaviorTests {
    let spy: AnalyticsTrackerSpy

    init() {
        spy = AnalyticsTrackerSpy()
    }

    @Test func track_appendsEvent() {
        spy.track(.appOpened)
        #expect(spy.eventCount == 1)
    }

    @Test func track_multipleEvents_appendsInOrder() {
        spy.track(.appOpened)
        spy.track(.screenViewed(name: "Home"))
        spy.track(.streakUpdated(count: 5))

        #expect(spy.eventCount == 3)
    }

    @Test func eventNames_areCorrect() {
        #expect(AnalyticsEvent.appOpened.name == "app_opened")
        #expect(AnalyticsEvent.screenViewed(name: "Test").name == "screen_viewed")
        #expect(AnalyticsEvent.streakUpdated(count: 7).name == "streak_updated")
        #expect(AnalyticsEvent.lessonStarted(chapterID: UUID(), lessonID: UUID()).name == "lesson_started")
        #expect(AnalyticsEvent.exerciseCompleted(type: "quiz", chapterID: UUID(), score: 0.8).name == "exercise_completed")
        #expect(AnalyticsEvent.sessionBooked(sessionID: UUID(), tutorID: UUID()).name == "session_booked")
        #expect(AnalyticsEvent.chapterCompleted(chapterID: UUID(), masteryScore: 0.9).name == "chapter_completed")
    }

    @Test func eventProperties_containExpectedKeys() {
        let lessonEvent = AnalyticsEvent.lessonStarted(chapterID: UUID(), lessonID: UUID())
        #expect(lessonEvent.properties.keys.contains("chapter_id"))
        #expect(lessonEvent.properties.keys.contains("lesson_id"))

        let sessionEvent = AnalyticsEvent.sessionBooked(sessionID: UUID(), tutorID: UUID())
        #expect(sessionEvent.properties.keys.contains("session_id"))
        #expect(sessionEvent.properties.keys.contains("tutor_id"))

        let appOpened = AnalyticsEvent.appOpened
        #expect(appOpened.properties.isEmpty)
    }

    @Test func exerciseCompleted_propertiesIncludeTypeAndScore() {
        let event = AnalyticsEvent.exerciseCompleted(type: "labeling", chapterID: UUID(), score: 0.85)
        #expect(event.properties["type"] == "labeling")
        #expect(event.properties["score"] == "0.85")
    }

    @Test func setUserProperties_mergesCorrectly() {
        spy.setUserProperties(["theme": "dark"])
        spy.setUserProperties(["language": "en"])

        #expect(spy.userProperties["theme"] == "dark")
        #expect(spy.userProperties["language"] == "en")
        #expect(spy.userProperties.count == 2)
    }

    @Test func setUserProperties_overwritesExistingKey() {
        spy.setUserProperties(["theme": "dark"])
        spy.setUserProperties(["theme": "light"])

        #expect(spy.userProperties["theme"] == "light")
    }

    @Test func flush_incrementsCallCount() {
        spy.flush()
        spy.flush()
        #expect(spy.flushCallCount == 2)
    }

    @Test func reset_clearsAllState() {
        spy.track(.appOpened)
        spy.setUserProperties(["key": "val"])
        spy.flush()

        spy.reset()

        #expect(spy.eventCount == 0)
        #expect(spy.userProperties.isEmpty)
        #expect(spy.flushCallCount == 0)
    }

    @Test func screenViewed_propertiesIncludeScreenName() {
        let event = AnalyticsEvent.screenViewed(name: "Subscription")
        #expect(event.properties["screen_name"] == "Subscription")
    }

    @Test func lessonCompleted_propertiesIncludeDuration() {
        let event = AnalyticsEvent.lessonCompleted(chapterID: UUID(), lessonID: UUID(), durationSeconds: 300)
        #expect(event.properties["duration_seconds"] == "300")
    }
}
