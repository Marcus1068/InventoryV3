//
//  InventoryItem.swift
//  InventoryV3
//
//  Created by Marcus Deuß on 09.03.26.
//
// Copyright 2026 Marcus Deuß
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.


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
