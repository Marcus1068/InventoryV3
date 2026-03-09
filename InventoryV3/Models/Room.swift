//
//  Room.swift
//  InventoryV3
//
//  Created by Marcus Deuß on 09.03.26.
//

import Foundation
import SwiftData

@Model
final class Room {
    var name: String = ""
    var sfSymbol: String = "house"
    var photoData: Data? = nil

    @Relationship(deleteRule: .nullify) var items: [InventoryItem]? = nil

    init() {}
}
