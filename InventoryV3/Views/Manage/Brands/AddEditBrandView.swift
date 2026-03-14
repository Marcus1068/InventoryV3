//
//  AddEditBrandView.swift
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

struct AddEditBrandView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let brand: Brand?
    var onCreated: ((Brand) -> Void)? = nil

    @State private var name: String
    @State private var sfSymbol: String

    @Query(sort: \Brand.name) private var existingBrands: [Brand]

    private var isDuplicate: Bool {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return false }
        return existingBrands.contains { b in
            b.name.localizedCaseInsensitiveCompare(trimmed) == .orderedSame && b !== brand
        }
    }

    private var canSave: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty && !isDuplicate }

    init(brand: Brand?, onCreated: ((Brand) -> Void)? = nil) {
        self.brand = brand
        self.onCreated = onCreated
        _name = State(initialValue: brand?.name ?? "")
        _sfSymbol = State(initialValue: brand?.sfSymbol ?? "tag")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Name", text: $name)
                    if isDuplicate {
                        Text("A brand with this name already exists.")
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
            .navigationTitle(brand == nil ? "Add Brand" : "Edit Brand")
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
        if let brand {
            brand.name = name
            brand.sfSymbol = sfSymbol
        } else {
            let newBrand = Brand()
            newBrand.name = name
            newBrand.sfSymbol = sfSymbol
            modelContext.insert(newBrand)
            onCreated?(newBrand)
        }
        dismiss()
    }
}
