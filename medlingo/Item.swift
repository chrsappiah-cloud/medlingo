//
//  Item.swift
//  medlingo
//
//  Created by Christopher Appiah-Thompson  on 6/5/2026.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
