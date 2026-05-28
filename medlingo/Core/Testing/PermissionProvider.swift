import Foundation

enum AppPermissionKind: String, Sendable, CaseIterable {
    case microphone
    case camera
    case notifications
}

enum PermissionStatus: String, Sendable {
    case notRequested
    case granted
    case denied
    case restricted
    case limited
}

protocol PermissionProviderProtocol: Sendable {
    func status(for permission: AppPermissionKind) -> PermissionStatus
}

struct LivePermissionProvider: PermissionProviderProtocol {
    func status(for permission: AppPermissionKind) -> PermissionStatus {
        switch permission {
        case .microphone, .camera:
            return .notRequested
        case .notifications:
            return .notRequested
        }
    }
}

struct FakePermissionProvider: PermissionProviderProtocol {
    var statuses: [AppPermissionKind: PermissionStatus]

    init(scenario: PermissionScenario?) {
        switch scenario {
        case .deniedMicrophone:
            statuses = [.microphone: .denied, .camera: .granted, .notifications: .granted]
        case .deniedCamera:
            statuses = [.microphone: .granted, .camera: .denied, .notifications: .granted]
        case .restricted:
            statuses = Dictionary(uniqueKeysWithValues: AppPermissionKind.allCases.map { ($0, .restricted) })
        case .limited:
            statuses = Dictionary(uniqueKeysWithValues: AppPermissionKind.allCases.map { ($0, .limited) })
        case .granted:
            statuses = Dictionary(uniqueKeysWithValues: AppPermissionKind.allCases.map { ($0, .granted) })
        case .notRequested, .none:
            statuses = Dictionary(uniqueKeysWithValues: AppPermissionKind.allCases.map { ($0, .notRequested) })
        }
    }

    func status(for permission: AppPermissionKind) -> PermissionStatus {
        statuses[permission] ?? .notRequested
    }
}

/// Policy helpers for permission-dependent UI copy and degradation.
enum PermissionPolicy {
    static func settingsRecoveryMessage(for status: PermissionStatus, permission: AppPermissionKind) -> String? {
        switch status {
        case .denied, .restricted:
            return "Open Settings to enable \(permission.rawValue) access for pronunciation and tutor sessions."
        case .limited:
            return "Limited \(permission.rawValue) access may block some features. You can change this in Settings."
        case .notRequested, .granted:
            return nil
        }
    }

    static func shouldBlockFeature(status: PermissionStatus) -> Bool {
        switch status {
        case .denied, .restricted: return true
        case .notRequested, .granted, .limited: return false
        }
    }
}
