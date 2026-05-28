import Foundation
@testable import medlingo

@MainActor
final class NavigatorSpy {
    private(set) var navigateToLearnCallCount = 0
    private(set) var navigateToPracticeCallCount = 0
    private(set) var popLearnCallCount = 0
    private(set) var resetAllCallCount = 0
    private(set) var lastLearnDestination: NavigationRouter.Destination?
    private(set) var lastPracticeDestination: NavigationRouter.Destination?

    func navigateToLearn(_ destination: NavigationRouter.Destination) {
        navigateToLearnCallCount += 1
        lastLearnDestination = destination
    }

    func navigateToPractice(_ destination: NavigationRouter.Destination) {
        navigateToPracticeCallCount += 1
        lastPracticeDestination = destination
    }

    func popLearn() {
        popLearnCallCount += 1
    }

    func resetAll() {
        resetAllCallCount += 1
    }
}
