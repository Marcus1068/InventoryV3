//
//  ItemCategory.swift
//  InventoryV3
//
//  Created by Marcus Deuß on 09.03.26.
//

import Foundation
import SwiftData

@Model
final class ItemCategory {
    var name: String = ""
    var sfSymbol: String = "square.grid.2x2"

    @Relationship(deleteRule: .nullify) var items: [InventoryItem]? = nil

    init() {}
}
