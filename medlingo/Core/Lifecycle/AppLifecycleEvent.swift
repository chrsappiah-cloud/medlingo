import Foundation

/// Typed lifecycle events that map Apple's scene-phase callbacks into domain events.
/// Using an enum makes event handling testable and keeps lifecycle logic centralised.
enum AppLifecycleEvent: Equatable, CustomStringConvertible {
    case launched
    case becameActive
    case willResignActive
    case enteredBackground
    case willEnterForeground
    case willTerminate
    case memoryWarning

    var description: String {
        switch self {
        case .launched:            return "launched"
        case .becameActive:        return "becameActive"
        case .willResignActive:    return "willResignActive"
        case .enteredBackground:   return "enteredBackground"
        case .willEnterForeground: return "willEnterForeground"
        case .willTerminate:       return "willTerminate"
        case .memoryWarning:       return "memoryWarning"
        }
    }
}
