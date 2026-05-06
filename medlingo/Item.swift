import Foundation
import SwiftData

// Legacy template model — retained for build compatibility.
// Replace with SharedModels in production.
@Model
final class Item {
    var timestamp: Date

    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
