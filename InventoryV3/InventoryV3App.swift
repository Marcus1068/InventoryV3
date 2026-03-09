//
//  InventoryV3App.swift
//  InventoryV3
//
//  Created by Marcus Deuß on 09.03.26.
//

import SwiftUI
import SwiftData

@main
struct InventoryV3App: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            InventoryItem.self,
            Room.self,
            Brand.self,
            ItemCategory.self,
            Owner.self
        ])
        let configuration = ModelConfiguration(
            schema: schema,
            cloudKitDatabase: .automatic
        )
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
