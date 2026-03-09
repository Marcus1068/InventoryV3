//
//  Brand.swift
//  InventoryV3
//
//  Created by Marcus Deuß on 09.03.26.
//

import Foundation
import SwiftData

@Model
final class Brand {
    var name: String = ""
    var sfSymbol: String = "tag"

    @Relationship(deleteRule: .nullify) var items: [InventoryItem]? = nil

    init() {}
}
