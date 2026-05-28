import Testing
@testable import medlingo

@MainActor
struct AppStateTests {
    @Test func isPremium_isTrue() {
        #expect(AppState.shared.isPremium == true)
    }

    @Test func isUITesting_whenLaunchArgSet_isTrue() {
        let config = AppLaunchConfiguration(arguments: ["-UITesting"])
        #expect(config.isUITestMode == true)
    }
}
