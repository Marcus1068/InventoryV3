//
//  InventoryDetailView.swift
//  InventoryV3
//
//  Created by Marcus Deuß on 09.03.26.
//

import SwiftUI
import SwiftData

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
    var body: some View {
        Section("Document") {
            Label("PDF attached", systemImage: "doc.fill")
                .foregroundStyle(.secondary)
        }
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
            if item.pdfData != nil {
                DocumentSection()
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
        }
    }
}
