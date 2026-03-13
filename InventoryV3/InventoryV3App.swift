//
//  InventoryV3App.swift
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
            #if targetEnvironment(macCatalyst)
            .task {
                // Configure resizability immediately, then wait for the system to
                // finish its own initial window placement before restoring our frame.
                WindowManager.configureResizability()
                try? await Task.sleep(for: .milliseconds(250))
                WindowManager.restoreFrame()
            }
            .task {
                // UIScene.willDeactivateNotification fires on both manual deactivation
                // and Cmd+Q quit — unlike scenePhase .inactive, which is skipped on quit.
                for await _ in NotificationCenter.default.notifications(
                    named: UIScene.willDeactivateNotification
                ) {
                    WindowManager.save()
                }
            }
            #endif
        }
        #if targetEnvironment(macCatalyst)
        .defaultSize(width: 1024, height: 768)
        #endif
        .modelContainer(sharedModelContainer)
    }
}
