import Testing
import Foundation
@testable import medlingo

struct AppLaunchConfigurationTests {
    @Test func isUITestMode_whenArgSet_isTrue() {
        let config = AppLaunchConfiguration(arguments: ["-UITesting"])
        #expect(config.isUITestMode == true)
    }

    @Test func isUITestMode_whenNotSet_isFalse() {
        let config = AppLaunchConfiguration(arguments: [])
        #expect(config.isUITestMode == false)
    }

    @Test func isOfflineNetwork_whenArgSet_isTrue() {
        let config = AppLaunchConfiguration(arguments: ["-mockNetwork", "offline"])
        #expect(config.isOfflineNetwork == true)
    }

    @Test func isOfflineNetwork_whenNotSet_isFalse() {
        let config = AppLaunchConfiguration(arguments: [])
        #expect(config.isOfflineNetwork == false)
    }

    @Test func seedsExpiredToken_whenArgSet_isTrue() {
        let config = AppLaunchConfiguration(arguments: ["-seedExpiredToken"])
        #expect(config.seedsExpiredToken == true)
    }

    @Test func seedsCreatorRole_whenArgSet_isTrue() {
        let config = AppLaunchConfiguration(arguments: ["-seedCreatorRole"])
        #expect(config.seedsCreatorRole == true)
    }

    @Test func forcesDemoAIGeneration_whenArgSet_isTrue() {
        let config = AppLaunchConfiguration(arguments: ["-mockAIGeneration"])
        #expect(config.forcesDemoAIGeneration == true)
    }

    @Test func forcesDemoAIGeneration_whenUITestAndCreator_isTrue() {
        let config = AppLaunchConfiguration(arguments: ["-UITesting", "-seedCreatorRole"])
        #expect(config.forcesDemoAIGeneration == true)
    }

    @Test func skipsOnboarding_whenUITestMode_isTrue() {
        let config = AppLaunchConfiguration(arguments: ["-UITesting"])
        #expect(config.skipsOnboarding == true)
    }

    @Test func permissionScenario_whenNotSet_isNil() {
        let config = AppLaunchConfiguration(arguments: [])
        #expect(config.permissionScenario == nil)
    }
}
