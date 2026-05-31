import Testing
@testable import medlingo

@MainActor
struct AppStateTests {
    @Test func isUITesting_whenLaunchArgSet_isTrue() {
        let config = AppLaunchConfiguration(arguments: ["-UITesting"])
        #expect(config.isUITestMode == true)
    }
}
