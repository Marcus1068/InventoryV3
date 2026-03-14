//
//  SampleDataGenerator.swift
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


import UIKit
import SwiftData

// MARK: - Result

struct SampleDataResult {
    let itemsInserted: Int
    let itemsSkipped: Int
    let supportingInserted: Int  // rooms + brands + categories + owners that were new

    var nothingAdded: Bool { itemsInserted == 0 && supportingInserted == 0 }
}

/// Inserts a set of demo rooms, brands, categories, owners, and inventory items.
/// Skips any entity whose name already exists (case-insensitive) to prevent duplicates.
enum SampleDataGenerator {

    @discardableResult
    static func generate(in context: ModelContext) -> SampleDataResult {
        // Pre-fetch all existing entities once to avoid repeated round-trips.
        let existingRooms      = (try? context.fetch(FetchDescriptor<Room>())) ?? []
        let existingBrands     = (try? context.fetch(FetchDescriptor<Brand>())) ?? []
        let existingCategories = (try? context.fetch(FetchDescriptor<ItemCategory>())) ?? []
        let existingOwners     = (try? context.fetch(FetchDescriptor<Owner>())) ?? []
        let existingItemNames  = Set(
            ((try? context.fetch(FetchDescriptor<InventoryItem>())) ?? []).map { $0.name.lowercased() }
        )

        var supportingInserted = 0
        var itemsInserted      = 0
        var itemsSkipped       = 0

        // MARK: Resolve helpers — find existing by name or create & insert

        func resolveRoom(_ name: String, symbol: String) -> Room {
            if let r = existingRooms.first(where: { $0.name.lowercased() == name.lowercased() }) { return r }
            let r = makeRoom(name, symbol: symbol)
            context.insert(r)
            supportingInserted += 1
            return r
        }

        func resolveBrand(_ name: String, symbol: String) -> Brand {
            if let b = existingBrands.first(where: { $0.name.lowercased() == name.lowercased() }) { return b }
            let b = makeBrand(name, symbol: symbol)
            context.insert(b)
            supportingInserted += 1
            return b
        }

        func resolveCategory(_ name: String, symbol: String) -> ItemCategory {
            if let c = existingCategories.first(where: { $0.name.lowercased() == name.lowercased() }) { return c }
            let c = makeCategory(name, symbol: symbol)
            context.insert(c)
            supportingInserted += 1
            return c
        }

        func resolveOwner(_ name: String) -> Owner {
            if let o = existingOwners.first(where: { $0.name.lowercased() == name.lowercased() }) { return o }
            let o = makeOwner(name)
            context.insert(o)
            supportingInserted += 1
            return o
        }

        // MARK: Rooms
        let living   = resolveRoom("Living Room",     symbol: "sofa")
        let kitchen  = resolveRoom("Kitchen",         symbol: "fork.knife")
        let bedroom  = resolveRoom("Bedroom",         symbol: "bed.double")
        let office   = resolveRoom("Office",          symbol: "desktopcomputer")
        let garage   = resolveRoom("Garage",          symbol: "car")
        let bathroom = resolveRoom("Bathroom",        symbol: "shower")
        let dining   = resolveRoom("Dining Room",     symbol: "fork.knife.circle")
        let kidsroom = resolveRoom("Children's Room", symbol: "gamecontroller")
        let basement = resolveRoom("Basement",        symbol: "archivebox")

        // MARK: Brands
        let apple   = resolveBrand("Apple",   symbol: "applelogo")
        let samsung = resolveBrand("Samsung", symbol: "tv")
        let ikea    = resolveBrand("IKEA",    symbol: "house")
        let sony    = resolveBrand("Sony",    symbol: "headphones")
        let bosch   = resolveBrand("Bosch",   symbol: "wrench.and.screwdriver")
        let lg      = resolveBrand("LG",      symbol: "display")
        let dyson   = resolveBrand("Dyson",   symbol: "wind")
        let miele   = resolveBrand("Miele",   symbol: "washer.fill")
        let philips = resolveBrand("Philips", symbol: "lightbulb.fill")
        let dewalt  = resolveBrand("DeWalt",  symbol: "hammer.fill")
        let canon   = resolveBrand("Canon",   symbol: "camera.fill")

        // MARK: Categories
        let electronics = resolveCategory("Electronics",       symbol: "bolt")
        let furniture   = resolveCategory("Furniture",         symbol: "chair")
        let appliances  = resolveCategory("Appliances",        symbol: "washer")
        let tools       = resolveCategory("Tools",             symbol: "hammer")
        let sports      = resolveCategory("Sports & Outdoors", symbol: "figure.run")
        let garden      = resolveCategory("Garden",            symbol: "leaf")

        // MARK: Owners
        let marcus = resolveOwner("Marcus")
        let anna   = resolveOwner("Anna")
        let lisa   = resolveOwner("Lisa")
        let tom    = resolveOwner("Tom")

        // MARK: Inventory Items helper

        func addItem(
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
        ) {
            guard !existingItemNames.contains(name.lowercased()) else {
                itemsSkipped += 1
                return
            }
            let item = makeItem(
                name, price: price, serial: serial,
                warranty: warranty, daysAgo: daysAgo, remark: remark,
                symbol: symbol, color: color,
                room: room, brand: brand, category: category, owner: owner
            )
            context.insert(item)
            itemsInserted += 1
        }

        // MARK: Inventory Items (50)

        // --- Electronics ---
        addItem("MacBook Pro",
                price: 2499.00, serial: "C02XG1YCHV2Q", warranty: 24, daysAgo: 5,
                remark: "Work laptop",
                symbol: "laptopcomputer", color: .systemBlue,
                room: office,   brand: apple,   category: electronics, owner: marcus)

        addItem("iPhone 15",
                price:  999.00, serial: "DNPXQ2M3LFWP", warranty: 12, daysAgo: 30,
                remark: "Personal phone",
                symbol: "iphone", color: .systemIndigo,
                room: living,   brand: apple,   category: electronics, owner: marcus)

        addItem("iPad Pro 13\"",
                price: 1299.00, serial: "DMPPQ4YCHV3R", warranty: 12, daysAgo: 60,
                remark: "M4 chip, Wi-Fi",
                symbol: "ipad", color: .systemBlue,
                room: living,   brand: apple,   category: electronics, owner: anna)

        addItem("Apple Watch Series 10",
                price:  499.00, serial: "G8WJK2PLMN4T", warranty: 12, daysAgo: 15,
                remark: "Titanium case",
                symbol: "applewatch", color: .systemGray,
                room: bedroom,  brand: apple,   category: electronics, owner: marcus)

        addItem("Apple AirPods Pro",
                price:  279.00, serial: "H9LKQ3RTXV5M", warranty: 12, daysAgo: 90,
                remark: "2nd generation, MagSafe",
                symbol: "airpodspro", color: .systemBlue,
                room: office,   brand: apple,   category: electronics, owner: marcus)

        addItem("Apple HomePod mini",
                price:   99.00, serial: "J2MNP7STWY8K", warranty: 12, daysAgo: 150,
                remark: "Kitchen speaker",
                symbol: "homepod.mini", color: .systemGray,
                room: kitchen,  brand: apple,   category: electronics, owner: anna)

        addItem("Apple TV 4K",
                price:  149.00, serial: "K3NQR8UVZX9L", warranty: 12, daysAgo: 200,
                remark: "3rd generation, Wi-Fi + Ethernet",
                symbol: "tv", color: .systemBlue,
                room: living,   brand: apple,   category: electronics, owner: anna)

        addItem("Apple Mac mini",
                price:  699.00, serial: "C02YR4TZHV1B", warranty: 24, daysAgo: 45,
                remark: "M4 chip, 16 GB RAM",
                symbol: "desktopcomputer", color: .systemGray,
                room: office,   brand: apple,   category: electronics, owner: tom)

        addItem("Samsung QLED TV",
                price: 1299.00, serial: "SN8K34LMN23",  warranty: 24, daysAgo: 90,
                remark: "65\" living room TV",
                symbol: "tv", color: .systemTeal,
                room: living,   brand: samsung, category: electronics, owner: anna)

        addItem("Samsung Galaxy S24 Ultra",
                price: 1199.00, serial: "R9WXZ5ABCD12", warranty: 24, daysAgo: 20,
                remark: "512 GB",
                symbol: "iphone", color: .systemBlue,
                room: dining,   brand: samsung, category: electronics, owner: tom)

        addItem("Samsung Galaxy Tab S9",
                price:  799.00, serial: "T4YZA6BCDE34", warranty: 24, daysAgo: 110,
                remark: "11\", Wi-Fi",
                symbol: "ipad", color: .systemBlue,
                room: kidsroom, brand: samsung, category: electronics, owner: tom)

        addItem("Sony WH-1000XM5",
                price:  349.00, serial: "SN4ABCD1234",  warranty: 12, daysAgo: 45,
                remark: "Noise-cancelling headphones",
                symbol: "headphones", color: .systemPurple,
                room: bedroom,  brand: sony,    category: electronics, owner: marcus)

        addItem("Sony Bravia 55\"",
                price:  899.00, serial: "SN7EFGH5678",  warranty: 24, daysAgo: 300,
                remark: "OLED, bedroom TV",
                symbol: "tv", color: .systemTeal,
                room: bedroom,  brand: sony,    category: electronics, owner: anna)

        addItem("Sony PlayStation 5",
                price:  499.00, serial: "SN2IJKL9012",  warranty: 12, daysAgo: 250,
                remark: "Disc edition",
                symbol: "gamecontroller", color: .systemPurple,
                room: living,   brand: sony,    category: electronics, owner: tom)

        addItem("LG OLED Monitor 27\"",
                price:  699.00, serial: "LG3MNOP3456",  warranty: 24, daysAgo: 55,
                remark: "4K, USB-C",
                symbol: "display", color: .systemBlue,
                room: office,   brand: lg,      category: electronics, owner: marcus)

        addItem("LG Soundbar",
                price:  349.00, serial: "LG5QRST7890",  warranty: 24, daysAgo: 130,
                remark: "3.1.2 ch, Dolby Atmos",
                symbol: "speaker.wave.3", color: .systemTeal,
                room: living,   brand: lg,      category: electronics, owner: tom)

        addItem("LG OLED TV 55\"",
                price: 1099.00, serial: "LG8UVWX1234",  warranty: 24, daysAgo: 180,
                remark: "Bedroom TV",
                symbol: "tv", color: .systemTeal,
                room: bedroom,  brand: lg,      category: electronics, owner: tom)

        addItem("Philips Hue Starter Kit",
                price:  199.00, serial: "",              warranty: 24, daysAgo: 160,
                remark: "Bridge + 4 bulbs, living room",
                symbol: "lightbulb.fill", color: .systemYellow,
                room: living,   brand: philips, category: electronics, owner: marcus)

        addItem("Philips Smart TV 43\"",
                price:  499.00, serial: "PH2BCDE5678",  warranty: 24, daysAgo: 220,
                remark: "Ambilight, dining room",
                symbol: "tv", color: .systemBlue,
                room: dining,   brand: philips, category: electronics, owner: lisa)

        addItem("Philips Wake-up Light",
                price:   89.00, serial: "",              warranty: 12, daysAgo: 400,
                remark: "Sunrise alarm",
                symbol: "sunrise.fill", color: .systemYellow,
                room: bedroom,  brand: philips, category: electronics, owner: lisa)

        addItem("Canon EOS R6 Mark II",
                price: 2499.00, serial: "CN1FGHIJ2345", warranty: 24, daysAgo: 70,
                remark: "Body only",
                symbol: "camera.fill", color: .systemOrange,
                room: office,   brand: canon,   category: electronics, owner: marcus)

        addItem("Canon PIXMA Printer",
                price:  149.00, serial: "CN4KLMN6789",  warranty: 12, daysAgo: 500,
                remark: "All-in-one, A4",
                symbol: "printer.fill", color: .systemGray,
                room: office,   brand: canon,   category: electronics, owner: anna)

        // --- Furniture ---
        addItem("IKEA Kallax Shelf",
                price:  149.00, serial: "",              warranty: 0,  daysAgo: 120,
                remark: "4×4 cube shelf",
                symbol: "square.grid.2x2", color: .systemOrange,
                room: living,   brand: ikea,    category: furniture,   owner: anna)

        addItem("IKEA Malm Bed",
                price:  399.00, serial: "",              warranty: 0,  daysAgo: 180,
                remark: "King size with storage",
                symbol: "bed.double.fill", color: .systemBrown,
                room: bedroom,  brand: ikea,    category: furniture,   owner: anna)

        addItem("IKEA Billy Bookcase",
                price:   79.00, serial: "",              warranty: 0,  daysAgo: 320,
                remark: "White, 80×202 cm",
                symbol: "books.vertical", color: .systemBrown,
                room: office,   brand: ikea,    category: furniture,   owner: anna)

        addItem("IKEA Poäng Armchair",
                price:  149.00, serial: "",              warranty: 0,  daysAgo: 500,
                remark: "Birch veneer",
                symbol: "chair", color: .systemOrange,
                room: living,   brand: ikea,    category: furniture,   owner: lisa)

        addItem("IKEA Hemnes Dresser",
                price:  249.00, serial: "",              warranty: 0,  daysAgo: 600,
                remark: "6-drawer, white stain",
                symbol: "cabinet", color: .systemBrown,
                room: bedroom,  brand: ikea,    category: furniture,   owner: lisa)

        addItem("IKEA Alex Desk",
                price:  199.00, serial: "",              warranty: 0,  daysAgo: 240,
                remark: "With drawers",
                symbol: "table.furniture", color: .systemOrange,
                room: kidsroom, brand: ikea,    category: furniture,   owner: tom)

        addItem("IKEA Trofast Storage",
                price:   99.00, serial: "",              warranty: 0,  daysAgo: 350,
                remark: "Kids toy storage",
                symbol: "square.grid.2x2", color: .systemBlue,
                room: kidsroom, brand: ikea,    category: furniture,   owner: tom)

        addItem("IKEA Pax Wardrobe",
                price:  599.00, serial: "",              warranty: 0,  daysAgo: 700,
                remark: "200×236 cm, with sliding doors",
                symbol: "cabinet", color: .systemBrown,
                room: bedroom,  brand: ikea,    category: furniture,   owner: anna)

        addItem("DeWalt Workbench",
                price:  349.00, serial: "",              warranty: 0,  daysAgo: 280,
                remark: "Folding, heavy duty",
                symbol: "table.furniture", color: .systemYellow,
                room: garage,   brand: dewalt,  category: furniture,   owner: marcus)

        // --- Appliances ---
        addItem("Bosch Dishwasher",
                price:  799.00, serial: "BSH00234AXY",  warranty: 24, daysAgo: 365,
                remark: "A+++ energy class",
                symbol: "washer.fill", color: .systemGreen,
                room: kitchen,  brand: bosch,   category: appliances,  owner: anna)

        addItem("Samsung Refrigerator",
                price:  999.00, serial: "RF23A9771SR",  warranty: 24, daysAgo: 400,
                remark: "Side-by-side, 600 L",
                symbol: "refrigerator.fill", color: .systemCyan,
                room: kitchen,  brand: samsung, category: appliances,  owner: anna)

        addItem("Bosch Built-in Oven",
                price:  649.00, serial: "BSH55OVN123",  warranty: 24, daysAgo: 550,
                remark: "Pyrolytic self-cleaning",
                symbol: "oven.fill", color: .systemOrange,
                room: kitchen,  brand: bosch,   category: appliances,  owner: anna)

        addItem("Dyson V15 Detect",
                price:  699.00, serial: "DY6RSTU4567",  warranty: 24, daysAgo: 85,
                remark: "Cordless, laser dust detection",
                symbol: "wind", color: .systemBlue,
                room: living,   brand: dyson,   category: appliances,  owner: anna)

        addItem("Dyson Airwrap",
                price:  499.00, serial: "DY3VWXY8901",  warranty: 24, daysAgo: 140,
                remark: "Complete Long",
                symbol: "wand.and.stars", color: .systemPink,
                room: bathroom, brand: dyson,   category: appliances,  owner: lisa)

        addItem("Miele Washing Machine",
                price:  999.00, serial: "MI7ZABC2345",  warranty: 24, daysAgo: 420,
                remark: "W1, 9 kg, A+++",
                symbol: "washer", color: .systemBlue,
                room: bathroom, brand: miele,   category: appliances,  owner: anna)

        addItem("Miele Tumble Dryer",
                price:  849.00, serial: "MI4DEFG6789",  warranty: 24, daysAgo: 420,
                remark: "T1, heat pump",
                symbol: "dryer.fill", color: .systemGray,
                room: bathroom, brand: miele,   category: appliances,  owner: anna)

        addItem("Miele Built-in Coffee Machine",
                price: 1299.00, serial: "MI9HIJK0123",  warranty: 24, daysAgo: 600,
                remark: "Fully automatic",
                symbol: "cup.and.saucer", color: .systemBrown,
                room: kitchen,  brand: miele,   category: appliances,  owner: anna)

        addItem("LG Microwave",
                price:  179.00, serial: "LG2LMNOP456",  warranty: 12, daysAgo: 310,
                remark: "Combi, 42 L",
                symbol: "microwave", color: .systemGray,
                room: kitchen,  brand: lg,      category: appliances,  owner: lisa)

        addItem("Philips Air Fryer",
                price:  129.00, serial: "",              warranty: 24, daysAgo: 190,
                remark: "XXL, 7.3 L",
                symbol: "flame.fill", color: .systemOrange,
                room: kitchen,  brand: philips, category: appliances,  owner: lisa)

        addItem("Philips Coffee Maker",
                price:   89.00, serial: "",              warranty: 12, daysAgo: 450,
                remark: "12-cup filter coffee",
                symbol: "cup.and.saucer", color: .systemBrown,
                room: dining,   brand: philips, category: appliances,  owner: lisa)

        addItem("Samsung Washing Machine",
                price:  699.00, serial: "SM3QRST7890",  warranty: 24, daysAgo: 380,
                remark: "8 kg, QuickDrive",
                symbol: "washer", color: .systemBlue,
                room: bathroom, brand: samsung, category: appliances,  owner: tom)

        addItem("Bosch Chest Freezer",
                price:  399.00, serial: "BSH22FRZ456",  warranty: 24, daysAgo: 650,
                remark: "200 L",
                symbol: "thermometer.snowflake", color: .systemCyan,
                room: basement, brand: bosch,   category: appliances,  owner: anna)

        // --- Tools ---
        addItem("Bosch Cordless Drill",
                price:  129.00, serial: "BSH9923KL1",   warranty: 24, daysAgo: 200,
                remark: "18 V, includes 2 batteries",
                symbol: "wrench.and.screwdriver.fill", color: .systemRed,
                room: garage,   brand: bosch,   category: tools,       owner: marcus)

        addItem("Bosch Angle Grinder",
                price:   99.00, serial: "BSH44AGR789",  warranty: 24, daysAgo: 410,
                remark: "125 mm, 1400 W",
                symbol: "gear.circle.fill", color: .systemRed,
                room: garage,   brand: bosch,   category: tools,       owner: marcus)

        addItem("DeWalt Jigsaw",
                price:  169.00, serial: "DW5UVWX1234",  warranty: 36, daysAgo: 260,
                remark: "18 V cordless",
                symbol: "scissors", color: .systemYellow,
                room: garage,   brand: dewalt,  category: tools,       owner: marcus)

        addItem("DeWalt Circular Saw",
                price:  219.00, serial: "DW8YZAB5678",  warranty: 36, daysAgo: 430,
                remark: "54 V FlexVolt",
                symbol: "circle.dotted.circle", color: .systemYellow,
                room: garage,   brand: dewalt,  category: tools,       owner: marcus)

        // --- Sports & Outdoors ---
        _ = sports  // referenced category; no sample items currently use it

        // --- Garden ---
        addItem("Bosch Lawn Mower",
                price:  449.00, serial: "BSH77LMW012",  warranty: 24, daysAgo: 480,
                remark: "Rotak 43, 43 cm cutting width",
                symbol: "leaf.fill", color: .systemGreen,
                room: garage,   brand: bosch,   category: garden,      owner: marcus)

        addItem("Philips Garden Lights",
                price:   79.00, serial: "",              warranty: 12, daysAgo: 530,
                remark: "Set of 6 spike lights",
                symbol: "sun.max.fill", color: .systemYellow,
                room: garage,   brand: philips, category: garden,      owner: tom)

        return SampleDataResult(
            itemsInserted: itemsInserted,
            itemsSkipped: itemsSkipped,
            supportingInserted: supportingInserted
        )
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
