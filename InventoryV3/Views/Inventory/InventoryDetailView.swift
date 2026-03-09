//
//  InventoryDetailView.swift
//  InventoryV3
//
//  Created by Marcus Deuß on 09.03.26.
//

import SwiftUI
import SwiftData

struct InventoryDetailView: View {
    let item: InventoryItem

    @State private var showingEdit = false

    var body: some View {
        List {
            photoSection
            detailsSection
            classifySection
            if item.pdfData != nil {
                documentSection
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

    // MARK: - Sections

    private var photoSection: some View {
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

    private var detailsSection: some View {
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

    private var classifySection: some View {
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

    private var documentSection: some View {
        Section("Document") {
            Label("PDF attached", systemImage: "doc.fill")
                .foregroundStyle(.secondary)
        }
    }
}
