//
//  InventoryDetailView.swift
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
import PDFKit
import QuickLook

// MARK: - Section Views

private struct PhotoSection: View {
    let item: InventoryItem

    var body: some View {
        Section {
            if let data = item.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, minHeight: 220, maxHeight: 280)
                    .clipped()
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            } else {
                Image(systemName: item.category?.sfSymbol ?? "square.grid.2x2")
                    .font(.system(size: 64))
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, minHeight: 140)
                    .glassEffect(.regular, in: .rect(cornerRadius: 16))
                    .listRowBackground(Color.clear)
                    .padding()
            }
        }
    }
}

private struct DetailsSection: View {
    let item: InventoryItem

    var body: some View {
        Section("Details") {
            LabeledContent("Name", value: item.name.isEmpty ? "—" : item.name)
            LabeledContent("Price") {
                Text(item.price, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
            }
            if !item.serialNumber.isEmpty {
                LabeledContent("Serial Number", value: item.serialNumber)
            }
            if item.warrantyMonths > 0 {
                LabeledContent("Warranty") {
                    Text("\(item.warrantyMonths) months")
                }
            }
            LabeledContent("Added", value: item.dateAdded.formatted(date: .abbreviated, time: .omitted))
            if !item.remark.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Remarks")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                    Text(item.remark)
                }
                .padding(.vertical, 2)
            }
        }
    }
}

private struct ClassifySection: View {
    let item: InventoryItem

    var body: some View {
        Section("Classify") {
            if let room = item.room {
                LabeledContent("Room") {
                    HStack {
                        if let data = room.photoData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 32, height: 32)
                                .clipShape(.rect(cornerRadius: 6))
                        }
                        Label(room.name, systemImage: room.sfSymbol)
                    }
                }
            }
            if let brand = item.brand {
                LabeledContent("Brand") {
                    Label(brand.name, systemImage: brand.sfSymbol)
                }
            }
            if let category = item.category {
                LabeledContent("Category") {
                    Label(category.name, systemImage: category.sfSymbol)
                }
            }
            if let owner = item.owner {
                LabeledContent("Owner", value: owner.name)
            }
        }
    }
}

private struct DocumentSection: View {
    let pdfData: Data

    @State private var thumbnail: UIImage?
    @State private var previewURL: URL?

    var body: some View {
        Section("Document") {
            if let thumbnail {
                Button {
                    let url = URL.temporaryDirectory.appending(path: "document-preview.pdf")
                    try? pdfData.write(to: url)
                    previewURL = url
                } label: {
                    VStack(alignment: .leading, spacing: 8) {
                        Image(uiImage: thumbnail)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: 240)
                            .clipShape(.rect(cornerRadius: 6))
                            .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                        Label("Tap to open PDF", systemImage: "doc.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
            } else {
                Label("PDF attached", systemImage: "doc.fill")
                    .foregroundStyle(.secondary)
            }
        }
        .task {
            guard let document = PDFDocument(data: pdfData),
                  let page = document.page(at: 0) else { return }
            let pageSize = page.bounds(for: .mediaBox).size
            let scale = 600.0 / max(pageSize.width, pageSize.height)
            let size = CGSize(width: pageSize.width * scale, height: pageSize.height * scale)
            thumbnail = page.thumbnail(of: size, for: .mediaBox)
        }
        .quickLookPreview($previewURL)
    }
}

// MARK: - Main View

struct InventoryDetailView: View {
    let item: InventoryItem

    @State private var showingEdit = false

    var body: some View {
        List {
            PhotoSection(item: item)
            DetailsSection(item: item)
            ClassifySection(item: item)
            if let pdfData = item.pdfData {
                DocumentSection(pdfData: pdfData)
            }
        }
        .navigationTitle(item.name.isEmpty ? "Item" : item.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit", systemImage: "pencil") {
                    showingEdit = true
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            AddEditInventoryView(item: item)
                .presentationSizing(.page)
        }
    }
}
