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
    @State private var showSplash = true

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
            ZStack {
                ContentView()
                #if !targetEnvironment(macCatalyst)
                if showSplash {
                    SplashScreenView {
                        withAnimation(.easeInOut(duration: 0.55)) {
                            showSplash = false
                        }
                    }
                    .transition(.opacity)
                    .zIndex(1)
                }
                #endif
            }
        }
        #if targetEnvironment(macCatalyst)
        .defaultSize(width: 1024, height: 768)
        #endif
        .modelContainer(sharedModelContainer)
    }
}
