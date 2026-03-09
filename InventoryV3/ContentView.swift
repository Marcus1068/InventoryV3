//
//  ContentView.swift
//  InventoryV3
//
//  Created by Marcus Deuß on 09.03.26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Inventory", systemImage: "list.bullet.rectangle") {
                InventoryGridView()
            }
            Tab("Manage", systemImage: "folder") {
                ManageView()
            }
            Tab("Reports", systemImage: "chart.bar") {
                ReportsView()
            }
            Tab("About", systemImage: "info.circle") {
                AboutView()
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(
            for: [InventoryItem.self, Room.self, Brand.self, ItemCategory.self, Owner.self],
            inMemory: true
        )
}
