import Testing
@testable import medlingo

struct PermissionPolicyTests {
    @Test func settingsRecoveryMessage_whenDenied_returnsCTA() {
        let message = PermissionPolicy.settingsRecoveryMessage(for: .denied, permission: .microphone)
        #expect(message?.contains("Settings") == true)
        #expect(message?.contains("microphone") == true)
    }

    @Test func settingsRecoveryMessage_whenGranted_returnsNil() {
        let message = PermissionPolicy.settingsRecoveryMessage(for: .granted, permission: .camera)
        #expect(message == nil)
    }

    @Test func shouldBlockFeature_whenRestricted_isTrue() {
        #expect(PermissionPolicy.shouldBlockFeature(status: .restricted) == true)
    }

    @Test func fakeProvider_deniedMicrophone_blocksMicrophoneOnly() {
        let provider = FakePermissionProvider(scenario: .deniedMicrophone)
        #expect(provider.status(for: .microphone) == .denied)
        #expect(provider.status(for: .camera) == .granted)
        #expect(PermissionPolicy.shouldBlockFeature(status: provider.status(for: .microphone)) == true)
    }

    @Test func launchConfiguration_mockPermissions_parsesDeniedCamera() {
        let config = AppLaunchConfiguration(arguments: ["-mockPermissions", "deniedCamera"])
        #expect(config.permissionScenario == PermissionScenario.deniedCamera)
    }
}
