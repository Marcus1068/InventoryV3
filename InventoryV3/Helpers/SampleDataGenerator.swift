//
//  SampleDataGenerator.swift
//  InventoryV3
//
//  Created by Marcus Deuß on 09.03.26.
//

import UIKit
import SwiftData

/// Inserts a set of demo rooms, brands, categories, owners, and inventory items.
enum SampleDataGenerator {

    static func generate(in context: ModelContext) {
        // MARK: Rooms
        let living  = makeRoom("Living Room", symbol: "sofa")
        let kitchen = makeRoom("Kitchen",     symbol: "fork.knife")
        let bedroom = makeRoom("Bedroom",     symbol: "bed.double")
        let office  = makeRoom("Office",      symbol: "desktopcomputer")
        let garage  = makeRoom("Garage",      symbol: "car")
        [living, kitchen, bedroom, office, garage].forEach { context.insert($0) }

        // MARK: Brands
        let apple   = makeBrand("Apple",   symbol: "applelogo")
        let samsung = makeBrand("Samsung", symbol: "tv")
        let ikea    = makeBrand("IKEA",    symbol: "house")
        let sony    = makeBrand("Sony",    symbol: "headphones")
        let bosch   = makeBrand("Bosch",   symbol: "wrench.and.screwdriver")
        [apple, samsung, ikea, sony, bosch].forEach { context.insert($0) }

        // MARK: Categories
        let electronics = makeCategory("Electronics", symbol: "bolt")
        let furniture   = makeCategory("Furniture",   symbol: "chair")
        let appliances  = makeCategory("Appliances",  symbol: "washer")
        let tools       = makeCategory("Tools",        symbol: "hammer")
        [electronics, furniture, appliances, tools].forEach { context.insert($0) }

        // MARK: Owners
        let marcus = makeOwner("Marcus")
        let anna   = makeOwner("Anna")
        [marcus, anna].forEach { context.insert($0) }

        // MARK: Inventory Items (10)
        let items: [InventoryItem] = [
            makeItem("MacBook Pro",
                     price: 2499.00, serial: "C02XG1YCHV2Q", warranty: 24, daysAgo: 0,
                     remark: "Work laptop",
                     symbol: "laptopcomputer", color: .systemBlue,
                     room: office,  brand: apple,   category: electronics, owner: marcus),

            makeItem("iPhone 15",
                     price:  999.00, serial: "DNPXQ2M3LFWP", warranty: 12, daysAgo: 30,
                     remark: "Personal phone",
                     symbol: "iphone", color: .systemIndigo,
                     room: living,  brand: apple,   category: electronics, owner: marcus),

            makeItem("iPad Pro 13\"",
                     price: 1299.00, serial: "DMPPQ4YCHV3R", warranty: 12, daysAgo: 60,
                     remark: "M4 chip, Wi-Fi",
                     symbol: "ipad", color: .systemBlue,
                     room: living,  brand: apple,   category: electronics, owner: anna),

            makeItem("Samsung QLED TV",
                     price: 1299.00, serial: "SN8K34LMN23", warranty: 24, daysAgo: 90,
                     remark: "65\" living room TV",
                     symbol: "tv", color: .systemTeal,
                     room: living,  brand: samsung, category: electronics, owner: anna),

            makeItem("Sony WH-1000XM5",
                     price:  349.00, serial: "SN4ABCD1234", warranty: 12, daysAgo: 45,
                     remark: "Noise-cancelling headphones",
                     symbol: "headphones", color: .systemPurple,
                     room: bedroom, brand: sony,    category: electronics, owner: marcus),

            makeItem("IKEA Kallax Shelf",
                     price:  149.00, serial: "", warranty: 0, daysAgo: 120,
                     remark: "4×4 cube shelf",
                     symbol: "square.grid.2x2", color: .systemOrange,
                     room: living,  brand: ikea,    category: furniture,   owner: anna),

            makeItem("IKEA Malm Bed",
                     price:  399.00, serial: "", warranty: 0, daysAgo: 180,
                     remark: "King size",
                     symbol: "bed.double.fill", color: .systemBrown,
                     room: bedroom, brand: ikea,    category: furniture,   owner: anna),

            makeItem("Bosch Cordless Drill",
                     price:  129.00, serial: "BSH9923KL1", warranty: 24, daysAgo: 200,
                     remark: "18 V, includes 2 batteries",
                     symbol: "wrench.and.screwdriver.fill", color: .systemRed,
                     room: garage,  brand: bosch,   category: tools,       owner: marcus),

            makeItem("Bosch Dishwasher",
                     price:  799.00, serial: "BSH00234AXY", warranty: 24, daysAgo: 365,
                     remark: "A+++ energy class",
                     symbol: "washer.fill", color: .systemGreen,
                     room: kitchen, brand: bosch,   category: appliances,  owner: anna),

            makeItem("Samsung Refrigerator",
                     price:  999.00, serial: "RF23A9771SR", warranty: 24, daysAgo: 400,
                     remark: "Side-by-side, 600 L",
                     symbol: "refrigerator.fill", color: .systemCyan,
                     room: kitchen, brand: samsung, category: appliances,  owner: anna),
        ]
        items.forEach { context.insert($0) }
    }

    // MARK: - Private factory helpers

    private static func makeRoom(_ name: String, symbol: String) -> Room {
        let r = Room()
        r.name = name
        r.sfSymbol = symbol
        return r
    }

    private static func makeBrand(_ name: String, symbol: String) -> Brand {
        let b = Brand()
        b.name = name
        b.sfSymbol = symbol
        return b
    }

    private static func makeCategory(_ name: String, symbol: String) -> ItemCategory {
        let c = ItemCategory()
        c.name = name
        c.sfSymbol = symbol
        return c
    }

    private static func makeOwner(_ name: String) -> Owner {
        let o = Owner()
        o.name = name
        return o
    }

    private static func makeItem(
        _ name: String,
        price: Double,
        serial: String,
        warranty: Int,
        daysAgo: Int,
        remark: String,
        symbol: String,
        color: UIColor,
        room: Room,
        brand: Brand,
        category: ItemCategory,
        owner: Owner
    ) -> InventoryItem {
        let item = InventoryItem()
        item.name = name
        item.price = price
        item.serialNumber = serial
        item.warrantyMonths = warranty
        item.remark = remark
        item.dateAdded = Calendar.current.date(byAdding: .day, value: -daysAgo, to: .now) ?? .now
        item.imageData = renderedSymbolImage(named: symbol, tintColor: color)
        item.room = room
        item.brand = brand
        item.category = category
        item.owner = owner
        return item
    }

    /// Renders an SF Symbol centred on a coloured rounded-rectangle background and returns JPEG data.
    private static func renderedSymbolImage(named symbolName: String, tintColor: UIColor) -> Data? {
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 80, weight: .regular)
        guard let symbol = UIImage(systemName: symbolName, withConfiguration: symbolConfig) else { return nil }

        let canvasSize = CGSize(width: 200, height: 200)
        let renderer = UIGraphicsImageRenderer(size: canvasSize)
        let image = renderer.image { _ in
            tintColor.withAlphaComponent(0.85).setFill()
            UIBezierPath(roundedRect: CGRect(origin: .zero, size: canvasSize), cornerRadius: 28).fill()

            let iconSize: CGFloat = 80
            let iconRect = CGRect(
                x: (canvasSize.width  - iconSize) / 2,
                y: (canvasSize.height - iconSize) / 2,
                width: iconSize,
                height: iconSize
            )
            symbol.withTintColor(.white, renderingMode: .alwaysOriginal).draw(in: iconRect)
        }
        return image.jpegData(compressionQuality: 0.8)
    }
}
