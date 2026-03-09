//
//  AddEditOwnerView.swift
//  InventoryV3
//
//  Created by Marcus Deuß on 09.03.26.
//

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

    private var canSave: Bool { !name.isEmpty }

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
