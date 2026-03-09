//
//  Owner.swift
//  InventoryV3
//
//  Created by Marcus Deuß on 09.03.26.
//

import Foundation
import SwiftData

@Model
final class Owner {
    var name: String = ""
    var imageData: Data? = nil

    @Relationship(deleteRule: .nullify) var items: [InventoryItem]? = nil

    init() {}
}
