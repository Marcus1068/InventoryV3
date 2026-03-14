//
//  AddEditOwnerView.swift
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
import PhotosUI

struct AddEditOwnerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let owner: Owner?
    var onCreated: ((Owner) -> Void)? = nil

    @State private var name: String
    @State private var imageData: Data?
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showingRemoveImageAlert = false

    @Query(sort: \Owner.name) private var existingOwners: [Owner]

    private var isDuplicate: Bool {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return false }
        return existingOwners.contains { o in
            o.name.localizedCaseInsensitiveCompare(trimmed) == .orderedSame && o !== owner
        }
    }

    private var canSave: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty && !isDuplicate }

    init(owner: Owner?, onCreated: ((Owner) -> Void)? = nil) {
        self.owner = owner
        self.onCreated = onCreated
        _name = State(initialValue: owner?.name ?? "")
        _imageData = State(initialValue: owner?.imageData)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Name", text: $name)
                    if isDuplicate {
                        Text("An owner with this name already exists.")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }

                Section("Photo") {
                    if let data = imageData, let uiImage = UIImage(data: data) {
                        HStack {
                            Spacer()
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(.circle)
                            Spacer()
                        }
                        .listRowBackground(Color.clear)
                        Button("Remove Photo", role: .destructive) {
                            showingRemoveImageAlert = true
                        }
                    }
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        Label("Choose from Library", systemImage: "photo.on.rectangle")
                    }
                }
            }
            .navigationTitle(owner == nil ? "Add Owner" : "Edit Owner")
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
            .task(id: selectedPhotoItem) {
                guard let item = selectedPhotoItem else { return }
                if let data = try? await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data),
                   let scaled = ImageHelper.downscaled(uiImage) {
                    imageData = scaled
                }
            }
            .alert("Remove Photo?", isPresented: $showingRemoveImageAlert) {
                Button("Remove", role: .destructive) { imageData = nil }
                Button("Cancel", role: .cancel) {}
            }
        }
    }

    private func save() {
        if let owner {
            owner.name = name
            owner.imageData = imageData
        } else {
            let newOwner = Owner()
            newOwner.name = name
            newOwner.imageData = imageData
            modelContext.insert(newOwner)
            onCreated?(newOwner)
        }
        dismiss()
    }
}
