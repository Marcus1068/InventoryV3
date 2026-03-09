//
//  AddEditRoomView.swift
//  InventoryV3
//
//  Created by Marcus Deuß on 09.03.26.
//

import SwiftUI
import SwiftData
import PhotosUI

struct AddEditRoomView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let room: Room?
    var onCreated: ((Room) -> Void)? = nil

    @State private var name: String
    @State private var sfSymbol: String
    @State private var photoData: Data?
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showingCamera = false

    private var canSave: Bool { !name.isEmpty }

    init(room: Room?, onCreated: ((Room) -> Void)? = nil) {
        self.room = room
        self.onCreated = onCreated
        _name = State(initialValue: room?.name ?? "")
        _sfSymbol = State(initialValue: room?.sfSymbol ?? "house")
        _photoData = State(initialValue: room?.photoData)
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

                Section("Photo") {
                    if let data = photoData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 160)
                            .clipShape(.rect(cornerRadius: 8))
                        Button("Remove Photo", role: .destructive) {
                            photoData = nil
                        }
                    }
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        Label("Choose from Library", systemImage: "photo.on.rectangle")
                    }
                    #if !targetEnvironment(macCatalyst)
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        Button("Take Photo", systemImage: "camera") {
                            showingCamera = true
                        }
                    }
                    #endif
                }
            }
            .navigationTitle(room == nil ? "Add Room" : "Edit Room")
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
            .sheet(isPresented: $showingCamera) {
                CameraPickerView { image in
                    photoData = ImageHelper.downscaled(image)
                }
            }
            .task(id: selectedPhotoItem) {
                guard let item = selectedPhotoItem else { return }
                if let data = try? await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data),
                   let scaled = ImageHelper.downscaled(uiImage) {
                    photoData = scaled
                }
            }
        }
    }

    private func save() {
        if let room {
            room.name = name
            room.sfSymbol = sfSymbol
            room.photoData = photoData
        } else {
            let newRoom = Room()
            newRoom.name = name
            newRoom.sfSymbol = sfSymbol
            newRoom.photoData = photoData
            modelContext.insert(newRoom)
            onCreated?(newRoom)
        }
        dismiss()
    }
}
