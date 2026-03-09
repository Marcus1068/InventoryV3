//
//  InventoryItem.swift
//  InventoryV3
//
//  Created by Marcus Deuß on 09.03.26.
//

import Foundation
import SwiftData

@Model
final class InventoryItem {
    var id: UUID = UUID()
    var name: String = ""
    var price: Double = 0.0
    var remark: String = ""
    var serialNumber: String = ""
    var warrantyMonths: Int = 0
    var dateAdded: Date = Date.now
    var imageData: Data? = nil
    var pdfData: Data? = nil

    @Relationship(deleteRule: .nullify, inverse: \Room.items) var room: Room? = nil
    @Relationship(deleteRule: .nullify, inverse: \Brand.items) var brand: Brand? = nil
    @Relationship(deleteRule: .nullify, inverse: \ItemCategory.items) var category: ItemCategory? = nil
    @Relationship(deleteRule: .nullify, inverse: \Owner.items) var owner: Owner? = nil

    init() {}
}
