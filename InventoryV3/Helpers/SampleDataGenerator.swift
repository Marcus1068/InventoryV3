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

/// Inserts a set of demo rooms, brands, categories, owners, and inventory items.
enum SampleDataGenerator {

    static func generate(in context: ModelContext) {
        // MARK: Rooms
        let living   = makeRoom("Living Room",    symbol: "sofa")
        let kitchen  = makeRoom("Kitchen",        symbol: "fork.knife")
        let bedroom  = makeRoom("Bedroom",        symbol: "bed.double")
        let office   = makeRoom("Office",         symbol: "desktopcomputer")
        let garage   = makeRoom("Garage",         symbol: "car")
        let bathroom = makeRoom("Bathroom",       symbol: "shower")
        let dining   = makeRoom("Dining Room",    symbol: "fork.knife.circle")
        let kidsroom = makeRoom("Children's Room", symbol: "gamecontroller")
        let basement = makeRoom("Basement",       symbol: "archivebox")
        [living, kitchen, bedroom, office, garage,
         bathroom, dining, kidsroom, basement].forEach { context.insert($0) }

        // MARK: Brands
        let apple   = makeBrand("Apple",   symbol: "applelogo")
        let samsung = makeBrand("Samsung", symbol: "tv")
        let ikea    = makeBrand("IKEA",    symbol: "house")
        let sony    = makeBrand("Sony",    symbol: "headphones")
        let bosch   = makeBrand("Bosch",   symbol: "wrench.and.screwdriver")
        let lg      = makeBrand("LG",      symbol: "display")
        let dyson   = makeBrand("Dyson",   symbol: "wind")
        let miele   = makeBrand("Miele",   symbol: "washer.fill")
        let philips = makeBrand("Philips", symbol: "lightbulb.fill")
        let dewalt  = makeBrand("DeWalt",  symbol: "hammer.fill")
        let canon   = makeBrand("Canon",   symbol: "camera.fill")
        [apple, samsung, ikea, sony, bosch,
         lg, dyson, miele, philips, dewalt, canon].forEach { context.insert($0) }

        // MARK: Categories
        let electronics = makeCategory("Electronics",      symbol: "bolt")
        let furniture   = makeCategory("Furniture",        symbol: "chair")
        let appliances  = makeCategory("Appliances",       symbol: "washer")
        let tools       = makeCategory("Tools",            symbol: "hammer")
        let sports      = makeCategory("Sports & Outdoors", symbol: "figure.run")
        let garden      = makeCategory("Garden",           symbol: "leaf")
        [electronics, furniture, appliances, tools, sports, garden].forEach { context.insert($0) }

        // MARK: Owners
        let marcus = makeOwner("Marcus")
        let anna   = makeOwner("Anna")
        let lisa   = makeOwner("Lisa")
        let tom    = makeOwner("Tom")
        [marcus, anna, lisa, tom].forEach { context.insert($0) }

        // MARK: Inventory Items (50)
        let items: [InventoryItem] = [

            // --- Electronics ---
            makeItem("MacBook Pro",
                     price: 2499.00, serial: "C02XG1YCHV2Q", warranty: 24, daysAgo: 5,
                     remark: "Work laptop",
                     symbol: "laptopcomputer", color: .systemBlue,
                     room: office,   brand: apple,   category: electronics, owner: marcus),

            makeItem("iPhone 15",
                     price:  999.00, serial: "DNPXQ2M3LFWP", warranty: 12, daysAgo: 30,
                     remark: "Personal phone",
                     symbol: "iphone", color: .systemIndigo,
                     room: living,   brand: apple,   category: electronics, owner: marcus),

            makeItem("iPad Pro 13\"",
                     price: 1299.00, serial: "DMPPQ4YCHV3R", warranty: 12, daysAgo: 60,
                     remark: "M4 chip, Wi-Fi",
                     symbol: "ipad", color: .systemBlue,
                     room: living,   brand: apple,   category: electronics, owner: anna),

            makeItem("Apple Watch Series 10",
                     price:  499.00, serial: "G8WJK2PLMN4T", warranty: 12, daysAgo: 15,
                     remark: "Titanium case",
                     symbol: "applewatch", color: .systemGray,
                     room: bedroom,  brand: apple,   category: electronics, owner: marcus),

            makeItem("Apple AirPods Pro",
                     price:  279.00, serial: "H9LKQ3RTXV5M", warranty: 12, daysAgo: 90,
                     remark: "2nd generation, MagSafe",
                     symbol: "airpodspro", color: .systemBlue,
                     room: office,   brand: apple,   category: electronics, owner: marcus),

            makeItem("Apple HomePod mini",
                     price:   99.00, serial: "J2MNP7STWY8K", warranty: 12, daysAgo: 150,
                     remark: "Kitchen speaker",
                     symbol: "homepod.mini", color: .systemGray,
                     room: kitchen,  brand: apple,   category: electronics, owner: anna),

            makeItem("Apple TV 4K",
                     price:  149.00, serial: "K3NQR8UVZX9L", warranty: 12, daysAgo: 200,
                     remark: "3rd generation, Wi-Fi + Ethernet",
                     symbol: "tv", color: .systemBlue,
                     room: living,   brand: apple,   category: electronics, owner: anna),

            makeItem("Apple Mac mini",
                     price:  699.00, serial: "C02YR4TZHV1B", warranty: 24, daysAgo: 45,
                     remark: "M4 chip, 16 GB RAM",
                     symbol: "desktopcomputer", color: .systemGray,
                     room: office,   brand: apple,   category: electronics, owner: tom),

            makeItem("Samsung QLED TV",
                     price: 1299.00, serial: "SN8K34LMN23",  warranty: 24, daysAgo: 90,
                     remark: "65\" living room TV",
                     symbol: "tv", color: .systemTeal,
                     room: living,   brand: samsung, category: electronics, owner: anna),

            makeItem("Samsung Galaxy S24 Ultra",
                     price: 1199.00, serial: "R9WXZ5ABCD12", warranty: 24, daysAgo: 20,
                     remark: "512 GB",
                     symbol: "iphone", color: .systemBlue,
                     room: dining,   brand: samsung, category: electronics, owner: tom),

            makeItem("Samsung Galaxy Tab S9",
                     price:  799.00, serial: "T4YZA6BCDE34", warranty: 24, daysAgo: 110,
                     remark: "11\", Wi-Fi",
                     symbol: "ipad", color: .systemBlue,
                     room: kidsroom, brand: samsung, category: electronics, owner: tom),

            makeItem("Sony WH-1000XM5",
                     price:  349.00, serial: "SN4ABCD1234",  warranty: 12, daysAgo: 45,
                     remark: "Noise-cancelling headphones",
                     symbol: "headphones", color: .systemPurple,
                     room: bedroom,  brand: sony,    category: electronics, owner: marcus),

            makeItem("Sony Bravia 55\"",
                     price:  899.00, serial: "SN7EFGH5678",  warranty: 24, daysAgo: 300,
                     remark: "OLED, bedroom TV",
                     symbol: "tv", color: .systemTeal,
                     room: bedroom,  brand: sony,    category: electronics, owner: anna),

            makeItem("Sony PlayStation 5",
                     price:  499.00, serial: "SN2IJKL9012",  warranty: 12, daysAgo: 250,
                     remark: "Disc edition",
                     symbol: "gamecontroller", color: .systemPurple,
                     room: living,   brand: sony,    category: electronics, owner: tom),

            makeItem("LG OLED Monitor 27\"",
                     price:  699.00, serial: "LG3MNOP3456",  warranty: 24, daysAgo: 55,
                     remark: "4K, USB-C",
                     symbol: "display", color: .systemBlue,
                     room: office,   brand: lg,      category: electronics, owner: marcus),

            makeItem("LG Soundbar",
                     price:  349.00, serial: "LG5QRST7890",  warranty: 24, daysAgo: 130,
                     remark: "3.1.2 ch, Dolby Atmos",
                     symbol: "speaker.wave.3", color: .systemTeal,
                     room: living,   brand: lg,      category: electronics, owner: tom),

            makeItem("LG OLED TV 55\"",
                     price: 1099.00, serial: "LG8UVWX1234",  warranty: 24, daysAgo: 180,
                     remark: "Bedroom TV",
                     symbol: "tv", color: .systemTeal,
                     room: bedroom,  brand: lg,      category: electronics, owner: tom),

            makeItem("Philips Hue Starter Kit",
                     price:  199.00, serial: "",              warranty: 24, daysAgo: 160,
                     remark: "Bridge + 4 bulbs, living room",
                     symbol: "lightbulb.fill", color: .systemYellow,
                     room: living,   brand: philips, category: electronics, owner: marcus),

            makeItem("Philips Smart TV 43\"",
                     price:  499.00, serial: "PH2BCDE5678",  warranty: 24, daysAgo: 220,
                     remark: "Ambilight, dining room",
                     symbol: "tv", color: .systemBlue,
                     room: dining,   brand: philips, category: electronics, owner: lisa),

            makeItem("Philips Wake-up Light",
                     price:   89.00, serial: "",              warranty: 12, daysAgo: 400,
                     remark: "Sunrise alarm",
                     symbol: "sunrise.fill", color: .systemYellow,
                     room: bedroom,  brand: philips, category: electronics, owner: lisa),

            makeItem("Canon EOS R6 Mark II",
                     price: 2499.00, serial: "CN1FGHIJ2345", warranty: 24, daysAgo: 70,
                     remark: "Body only",
                     symbol: "camera.fill", color: .systemOrange,
                     room: office,   brand: canon,   category: electronics, owner: marcus),

            makeItem("Canon PIXMA Printer",
                     price:  149.00, serial: "CN4KLMN6789",  warranty: 12, daysAgo: 500,
                     remark: "All-in-one, A4",
                     symbol: "printer.fill", color: .systemGray,
                     room: office,   brand: canon,   category: electronics, owner: anna),

            // --- Furniture ---
            makeItem("IKEA Kallax Shelf",
                     price:  149.00, serial: "",              warranty: 0,  daysAgo: 120,
                     remark: "4×4 cube shelf",
                     symbol: "square.grid.2x2", color: .systemOrange,
                     room: living,   brand: ikea,    category: furniture,   owner: anna),

            makeItem("IKEA Malm Bed",
                     price:  399.00, serial: "",              warranty: 0,  daysAgo: 180,
                     remark: "King size with storage",
                     symbol: "bed.double.fill", color: .systemBrown,
                     room: bedroom,  brand: ikea,    category: furniture,   owner: anna),

            makeItem("IKEA Billy Bookcase",
                     price:   79.00, serial: "",              warranty: 0,  daysAgo: 320,
                     remark: "White, 80×202 cm",
                     symbol: "books.vertical", color: .systemBrown,
                     room: office,   brand: ikea,    category: furniture,   owner: anna),

            makeItem("IKEA Poäng Armchair",
                     price:  149.00, serial: "",              warranty: 0,  daysAgo: 500,
                     remark: "Birch veneer",
                     symbol: "chair", color: .systemOrange,
                     room: living,   brand: ikea,    category: furniture,   owner: lisa),

            makeItem("IKEA Hemnes Dresser",
                     price:  249.00, serial: "",              warranty: 0,  daysAgo: 600,
                     remark: "6-drawer, white stain",
                     symbol: "cabinet", color: .systemBrown,
                     room: bedroom,  brand: ikea,    category: furniture,   owner: lisa),

            makeItem("IKEA Alex Desk",
                     price:  199.00, serial: "",              warranty: 0,  daysAgo: 240,
                     remark: "With drawers",
                     symbol: "table.furniture", color: .systemOrange,
                     room: kidsroom, brand: ikea,    category: furniture,   owner: tom),

            makeItem("IKEA Trofast Storage",
                     price:   99.00, serial: "",              warranty: 0,  daysAgo: 350,
                     remark: "Kids toy storage",
                     symbol: "square.grid.2x2", color: .systemBlue,
                     room: kidsroom, brand: ikea,    category: furniture,   owner: tom),

            makeItem("IKEA Pax Wardrobe",
                     price:  599.00, serial: "",              warranty: 0,  daysAgo: 700,
                     remark: "200×236 cm, with sliding doors",
                     symbol: "cabinet", color: .systemBrown,
                     room: bedroom,  brand: ikea,    category: furniture,   owner: anna),

            makeItem("DeWalt Workbench",
                     price:  349.00, serial: "",              warranty: 0,  daysAgo: 280,
                     remark: "Folding, heavy duty",
                     symbol: "table.furniture", color: .systemYellow,
                     room: garage,   brand: dewalt,  category: furniture,   owner: marcus),

            // --- Appliances ---
            makeItem("Bosch Dishwasher",
                     price:  799.00, serial: "BSH00234AXY",  warranty: 24, daysAgo: 365,
                     remark: "A+++ energy class",
                     symbol: "washer.fill", color: .systemGreen,
                     room: kitchen,  brand: bosch,   category: appliances,  owner: anna),

            makeItem("Samsung Refrigerator",
                     price:  999.00, serial: "RF23A9771SR",  warranty: 24, daysAgo: 400,
                     remark: "Side-by-side, 600 L",
                     symbol: "refrigerator.fill", color: .systemCyan,
                     room: kitchen,  brand: samsung, category: appliances,  owner: anna),

            makeItem("Bosch Built-in Oven",
                     price:  649.00, serial: "BSH55OVN123",  warranty: 24, daysAgo: 550,
                     remark: "Pyrolytic self-cleaning",
                     symbol: "oven.fill", color: .systemOrange,
                     room: kitchen,  brand: bosch,   category: appliances,  owner: anna),

            makeItem("Dyson V15 Detect",
                     price:  699.00, serial: "DY6RSTU4567",  warranty: 24, daysAgo: 85,
                     remark: "Cordless, laser dust detection",
                     symbol: "wind", color: .systemBlue,
                     room: living,   brand: dyson,   category: appliances,  owner: anna),

            makeItem("Dyson Airwrap",
                     price:  499.00, serial: "DY3VWXY8901",  warranty: 24, daysAgo: 140,
                     remark: "Complete Long",
                     symbol: "wand.and.stars", color: .systemPink,
                     room: bathroom, brand: dyson,   category: appliances,  owner: lisa),

            makeItem("Miele Washing Machine",
                     price:  999.00, serial: "MI7ZABC2345",  warranty: 24, daysAgo: 420,
                     remark: "W1, 9 kg, A+++",
                     symbol: "washer", color: .systemBlue,
                     room: bathroom, brand: miele,   category: appliances,  owner: anna),

            makeItem("Miele Tumble Dryer",
                     price:  849.00, serial: "MI4DEFG6789",  warranty: 24, daysAgo: 420,
                     remark: "T1, heat pump",
                     symbol: "dryer.fill", color: .systemGray,
                     room: bathroom, brand: miele,   category: appliances,  owner: anna),

            makeItem("Miele Built-in Coffee Machine",
                     price: 1299.00, serial: "MI9HIJK0123",  warranty: 24, daysAgo: 600,
                     remark: "Fully automatic",
                     symbol: "cup.and.saucer", color: .systemBrown,
                     room: kitchen,  brand: miele,   category: appliances,  owner: anna),

            makeItem("LG Microwave",
                     price:  179.00, serial: "LG2LMNOP456",  warranty: 12, daysAgo: 310,
                     remark: "Combi, 42 L",
                     symbol: "microwave", color: .systemGray,
                     room: kitchen,  brand: lg,      category: appliances,  owner: lisa),

            makeItem("Philips Air Fryer",
                     price:  129.00, serial: "",              warranty: 24, daysAgo: 190,
                     remark: "XXL, 7.3 L",
                     symbol: "flame.fill", color: .systemOrange,
                     room: kitchen,  brand: philips, category: appliances,  owner: lisa),

            makeItem("Philips Coffee Maker",
                     price:   89.00, serial: "",              warranty: 12, daysAgo: 450,
                     remark: "12-cup filter coffee",
                     symbol: "cup.and.saucer", color: .systemBrown,
                     room: dining,   brand: philips, category: appliances,  owner: lisa),

            makeItem("Samsung Washing Machine",
                     price:  699.00, serial: "SM3QRST7890",  warranty: 24, daysAgo: 380,
                     remark: "8 kg, QuickDrive",
                     symbol: "washer", color: .systemBlue,
                     room: bathroom, brand: samsung, category: appliances,  owner: tom),

            makeItem("Bosch Chest Freezer",
                     price:  399.00, serial: "BSH22FRZ456",  warranty: 24, daysAgo: 650,
                     remark: "200 L",
                     symbol: "thermometer.snowflake", color: .systemCyan,
                     room: basement, brand: bosch,   category: appliances,  owner: anna),

            // --- Tools ---
            makeItem("Bosch Cordless Drill",
                     price:  129.00, serial: "BSH9923KL1",   warranty: 24, daysAgo: 200,
                     remark: "18 V, includes 2 batteries",
                     symbol: "wrench.and.screwdriver.fill", color: .systemRed,
                     room: garage,   brand: bosch,   category: tools,       owner: marcus),

            makeItem("Bosch Angle Grinder",
                     price:   99.00, serial: "BSH44AGR789",  warranty: 24, daysAgo: 410,
                     remark: "125 mm, 1400 W",
                     symbol: "gear.circle.fill", color: .systemRed,
                     room: garage,   brand: bosch,   category: tools,       owner: marcus),

            makeItem("DeWalt Jigsaw",
                     price:  169.00, serial: "DW5UVWX1234",  warranty: 36, daysAgo: 260,
                     remark: "18 V cordless",
                     symbol: "scissors", color: .systemYellow,
                     room: garage,   brand: dewalt,  category: tools,       owner: marcus),

            makeItem("DeWalt Circular Saw",
                     price:  219.00, serial: "DW8YZAB5678",  warranty: 36, daysAgo: 430,
                     remark: "54 V FlexVolt",
                     symbol: "circle.dotted.circle", color: .systemYellow,
                     room: garage,   brand: dewalt,  category: tools,       owner: marcus),

            // --- Garden ---
            makeItem("Bosch Lawn Mower",
                     price:  449.00, serial: "BSH77LMW012",  warranty: 24, daysAgo: 480,
                     remark: "Rotak 43, 43 cm cutting width",
                     symbol: "leaf.fill", color: .systemGreen,
                     room: garage,   brand: bosch,   category: garden,      owner: marcus),

            makeItem("Philips Garden Lights",
                     price:   79.00, serial: "",              warranty: 12, daysAgo: 530,
                     remark: "Set of 6 spike lights",
                     symbol: "sun.max.fill", color: .systemYellow,
                     room: garage,   brand: philips, category: garden,      owner: tom),
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
