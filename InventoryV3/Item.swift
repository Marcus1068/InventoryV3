//
//  Item.swift
//  InventoryV3
//
//  Created by Marcus Deuß on 09.03.26.
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
