//
//  AddEditCategoryView.swift
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

struct AddEditCategoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let category: ItemCategory?
    var onCreated: ((ItemCategory) -> Void)? = nil

    @State private var name: String
    @State private var sfSymbol: String

    @Query(sort: \ItemCategory.name) private var existingCategories: [ItemCategory]

    private var isDuplicate: Bool {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return false }
        return existingCategories.contains { c in
            c.name.localizedCaseInsensitiveCompare(trimmed) == .orderedSame && c !== category
        }
    }

    private var canSave: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty && !isDuplicate }

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
                    if isDuplicate {
                        Text("A category with this name already exists.")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
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
