//
//  AboutView.swift
//  InventoryV3
//
//  Created by Marcus Deuß on 09.03.26.
//

import SwiftUI
import SwiftData

struct AboutView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showSampleDataConfirmation = false
    @State private var showSampleDataSuccess = false

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
                            SampleDataGenerator.generate(in: modelContext)
                            showSampleDataSuccess = true
                        }
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        Text("This will add sample rooms, brands, categories, owners, and 10 inventory items to your existing data.")
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
                Text("10 sample inventory items with rooms, brands, categories, and owners have been added.")
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
