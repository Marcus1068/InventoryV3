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

// MARK: - What's New card

private struct WhatsNewFeature: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
}

private struct WhatsNewCard: View {
    let version: String
    let features: [WhatsNewFeature]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("What's New")
                        .font(.title2)
                        .bold()
                    Text("Version \(version)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "sparkles")
                    .font(.title)
                    .foregroundStyle(.yellow)
            }

            Divider()

            ForEach(features) { feature in
                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: feature.icon)
                        .font(.title3)
                        .foregroundStyle(.tint)
                        .frame(width: 28, alignment: .center)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(feature.title)
                            .bold()
                        Text(feature.description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: .rect(cornerRadius: 16))
    }
}

// MARK: - Privacy card

private struct PrivacyPoint: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
}

private struct PrivacyCard: View {
    private let points: [PrivacyPoint] = [
        PrivacyPoint(
            icon: "icloud.fill",
            title: "iCloud Storage & Sync",
            description: "All your inventory data is stored exclusively in your personal iCloud account and synced across your Apple devices. No third-party servers are involved."
        ),
        PrivacyPoint(
            icon: "lock.shield.fill",
            title: "No Data Collection",
            description: "This app does not collect, transmit, or process any personal or inventory data outside of your iCloud account. Your data is yours alone."
        ),
        PrivacyPoint(
            icon: "eye.slash.fill",
            title: "No Tracking",
            description: "No analytics, advertising SDKs, or tracking frameworks are used. Your usage of this app is never monitored or profiled."
        ),
        PrivacyPoint(
            icon: "person.slash.fill",
            title: "No Account Required",
            description: "No registration, login, or user account beyond your Apple ID is required. There is no backend service associated with this app."
        ),
        PrivacyPoint(
            icon: "photo.fill",
            title: "Photos & Documents Stay Local",
            description: "Photos and PDF documents attached to items are stored only in your iCloud database. They are never uploaded to any external service."
        ),
        PrivacyPoint(
            icon: "checkmark.shield.fill",
            title: "Apple Privacy Standards",
            description: "This app is built to comply with Apple's App Store privacy guidelines and applicable data protection regulations including GDPR."
        ),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Privacy")
                        .font(.title2)
                        .bold()
                    Text("Your data, your control")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "lock.shield.fill")
                    .font(.title)
                    .foregroundStyle(.green)
            }

            Divider()

            ForEach(points) { point in
                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: point.icon)
                        .font(.title3)
                        .foregroundStyle(.green)
                        .frame(width: 28, alignment: .center)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(point.title)
                            .bold()
                        Text(point.description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: .rect(cornerRadius: 16))
    }
}

// MARK: - About View

struct AboutView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showSampleDataConfirmation = false
    @State private var showSampleDataSuccess = false
    @State private var showNothingAdded = false
    @State private var sampleDataResult: SampleDataResult?
    @State private var showDeleteAllConfirmation = false

    @AppStorage("ownerName")    private var ownerName: String = ""
    @AppStorage("ownerAddress") private var ownerAddress: String = ""

    var body: some View {
        NavigationStack {
            List {
                Section {
                    AboutLogoView()
                }
                .listRowBackground(Color.clear)

                Section {
                    WhatsNewCard(
                        version: Bundle.main.appVersion,
                        features: [
                            WhatsNewFeature(
                                icon: "checkmark.seal",
                                title: "Unique Names",
                                description: "Rooms, brands, categories, and owners now prevent duplicate names with an inline warning."
                            ),
                            WhatsNewFeature(
                                icon: "doc.viewfinder",
                                title: "PDF Preview",
                                description: "A thumbnail of the first page is shown when a PDF document is attached. Tap to open the full document."
                            ),
                            WhatsNewFeature(
                                icon: "dollarsign.circle",
                                title: "Overall Price Sum",
                                description: "The inventory banner shows the total value of all visible items, updated live when searching or filtering."
                            ),
                            WhatsNewFeature(
                                icon: "tablecells.badge.ellipsis",
                                title: "Improved CSV Export",
                                description: "Exporting now produces a real .csv file on both iOS and macOS, shareable directly to Files."
                            ),
                            WhatsNewFeature(
                                icon: "arrow.up.left.and.arrow.down.right",
                                title: "Larger Add/Edit Sheet",
                                description: "The inventory add and edit form now opens as a full-page sheet on iPad and Mac."
                            ),
                        ]
                    )
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))

                Section {
                    TextField("Name", text: $ownerName)
                    TextField("Address", text: $ownerAddress, axis: .vertical)
                        .lineLimit(2...5)
                } header: {
                    Text("Profile")
                } footer: {
                    Text("Your name and address appear at the top of generated PDF reports.")
                }

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
                    VStack(alignment: .leading, spacing: 6) {
                        Text("© \(Date.now.formatted(.dateTime.year())) Marcus Deuß")
                            .bold()
                        Text("All rights reserved.")
                            .foregroundStyle(.secondary)
                    }
                    LabeledContent("Version", value: Bundle.main.appVersion)
                        .foregroundStyle(.secondary)
                    Link(destination: URL(string: "https://www.apache.org/licenses/LICENSE-2.0")!) {
                        Label("Apache License 2.0", systemImage: "doc.plaintext")
                    }
                }

                Section {
                    PrivacyCard()
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
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
