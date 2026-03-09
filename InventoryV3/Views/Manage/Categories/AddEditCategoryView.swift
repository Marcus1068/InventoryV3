//
//  AddEditCategoryView.swift
//  InventoryV3
//
//  Created by Marcus Deuß on 09.03.26.
//

import SwiftUI
import SwiftData

struct AddEditCategoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let category: ItemCategory?
    var onCreated: ((ItemCategory) -> Void)? = nil

    @State private var name: String
    @State private var sfSymbol: String

    private var canSave: Bool { !name.isEmpty }

    init(category: ItemCategory?, onCreated: ((ItemCategory) -> Void)? = nil) {
        self.category = category
        self.onCreated = onCreated
        _name = State(initialValue: category?.name ?? "")
        _sfSymbol = State(initialValue: category?.sfSymbol ?? "square.grid.2x2")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Name", text: $name)
                    NavigationLink {
                        SFSymbolPicker(selection: $sfSymbol)
                    } label: {
                        HStack {
                            Text("Symbol")
                            Spacer()
                            Image(systemName: sfSymbol)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle(category == nil ? "Add Category" : "Edit Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(!canSave)
                }
            }
        }
    }

    private func save() {
        if let category {
            category.name = name
            category.sfSymbol = sfSymbol
        } else {
            let newCategory = ItemCategory()
            newCategory.name = name
            newCategory.sfSymbol = sfSymbol
            modelContext.insert(newCategory)
            onCreated?(newCategory)
        }
        dismiss()
    }
}
