//
//  AboutView.swift
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

struct AboutView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showSampleDataConfirmation = false
    @State private var showSampleDataSuccess = false
    @State private var showNothingAdded = false
    @State private var sampleDataResult: SampleDataResult?
    @State private var showDeleteAllConfirmation = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    AboutLogoView()
                }
                .listRowBackground(Color.clear)

                Section("Links") {
                    Link(destination: URL(string: "https://github.com/Marcus1068/InventoryV3")!) {
                        Label("GitHub Repository", systemImage: "link")
                    }
                }

                Section("Developer") {
                    Button("Load Sample Data", systemImage: "wand.and.sparkles") {
                        showSampleDataConfirmation = true
                    }
                    .confirmationDialog(
                        "Load Sample Data",
                        isPresented: $showSampleDataConfirmation
                    ) {
                        Button("Load Sample Data") {
                            let result = SampleDataGenerator.generate(in: modelContext)
                            sampleDataResult = result
                            if result.nothingAdded {
                                showNothingAdded = true
                            } else {
                                showSampleDataSuccess = true
                            }
                        }
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        Text("This will add sample rooms, brands, categories, owners, and 50 inventory items to your existing data.")
                    }

                    Button("Delete All Data", systemImage: "trash") {
                        showDeleteAllConfirmation = true
                    }
                    .foregroundStyle(.red)
                    .confirmationDialog(
                        "Delete All Data",
                        isPresented: $showDeleteAllConfirmation
                    ) {
                        Button("Delete All Data", role: .destructive) {
                            try? modelContext.delete(model: InventoryItem.self)
                            try? modelContext.delete(model: Room.self)
                            try? modelContext.delete(model: Brand.self)
                            try? modelContext.delete(model: ItemCategory.self)
                            try? modelContext.delete(model: Owner.self)
                        }
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        Text("This will permanently delete all inventory items, rooms, brands, categories, and owners. This cannot be undone.")
                    }
                }

                Section("Legal") {
                    Text("© \(Date.now.formatted(.dateTime.year())) Marcus Deuß. All rights reserved.")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("About")
            .alert("Sample Data Loaded", isPresented: $showSampleDataSuccess) {
                Button("OK") {}
            } message: {
                if let r = sampleDataResult {
                    if r.itemsSkipped > 0 {
                        Text("Added ^[\(r.itemsInserted) item](inflect: true). ^[\(r.itemsSkipped) item](inflect: true) already existed and \(r.itemsSkipped == 1 ? "was" : "were") skipped.")
                    } else {
                        Text("Added ^[\(r.itemsInserted) item](inflect: true) with rooms, brands, categories, and owners.")
                    }
                }
            }
            .alert("Nothing Added", isPresented: $showNothingAdded) {
                Button("OK") {}
            } message: {
                Text("All sample data already exists in your inventory. No duplicates were inserted.")
            }
        }
    }
}

extension Bundle {
    var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}

#Preview {
    AboutView()
}
