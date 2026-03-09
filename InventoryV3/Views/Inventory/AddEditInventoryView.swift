//
//  AddEditInventoryView.swift
//  InventoryV3
//
//  Created by Marcus Deuß on 09.03.26.
//

import SwiftUI
import SwiftData
import PhotosUI
import UniformTypeIdentifiers

// MARK: - Sheet Destination

private enum AddRelatedSheet: Identifiable {
    case room, brand, category, owner
    var id: Self { self }
}

// MARK: - View Model

@Observable
final class AddEditInventoryViewModel {
    var name: String
    var price: Double
    var remark: String
    var serialNumber: String
    var warrantyMonths: Int
    var imageData: Data?
    var pdfData: Data?
    var selectedRoom: Room?
    var selectedBrand: Brand?
    var selectedCategory: ItemCategory?
    var selectedOwner: Owner?

    var canSave: Bool {
        !name.isEmpty
            && selectedRoom != nil
            && selectedBrand != nil
            && selectedCategory != nil
            && selectedOwner != nil
    }

    init(item: InventoryItem?) {
        name = item?.name ?? ""
        price = item?.price ?? 0.0
        remark = item?.remark ?? ""
        serialNumber = item?.serialNumber ?? ""
        warrantyMonths = item?.warrantyMonths ?? 0
        imageData = item?.imageData
        pdfData = item?.pdfData
        selectedRoom = item?.room
        selectedBrand = item?.brand
        selectedCategory = item?.category
        selectedOwner = item?.owner
    }

    func save(item: InventoryItem?, context: ModelContext) {
        let target = item ?? InventoryItem()
        target.name = name
        target.price = price
        target.remark = remark
        target.serialNumber = serialNumber
        target.warrantyMonths = warrantyMonths
        target.imageData = imageData
        target.pdfData = pdfData
        target.room = selectedRoom
        target.brand = selectedBrand
        target.category = selectedCategory
        target.owner = selectedOwner
        if item == nil {
            context.insert(target)
        }
    }
}

// MARK: - View

struct AddEditInventoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Room.name) private var rooms: [Room]
    @Query(sort: \Brand.name) private var brands: [Brand]
    @Query(sort: \ItemCategory.name) private var categories: [ItemCategory]
    @Query(sort: \Owner.name) private var owners: [Owner]

    let item: InventoryItem?

    @State private var viewModel: AddEditInventoryViewModel
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showingCamera = false
    @State private var showingFilePicker = false
    @State private var showingRemoveImageAlert = false
    @State private var addRelatedSheet: AddRelatedSheet?

    init(item: InventoryItem?) {
        self.item = item
        _viewModel = State(initialValue: AddEditInventoryViewModel(item: item))
    }

    var body: some View {
        NavigationStack {
            Form {
                detailsSection
                warrantySection
                photoSection
                documentSection
                classifySection
            }
            .navigationTitle(item == nil ? "Add Item" : "Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.save(item: item, context: modelContext)
                        dismiss()
                    }
                    .disabled(!viewModel.canSave)
                }
            }
            #if !targetEnvironment(macCatalyst)
            .sheet(isPresented: $showingCamera) {
                CameraPickerView { image in
                    if let data = ImageHelper.downscaled(image) {
                        viewModel.imageData = data
                    }
                }
            }
            #endif
            .fileImporter(
                isPresented: $showingFilePicker,
                allowedContentTypes: [.pdf]
            ) { result in
                if case .success(let url) = result {
                    guard url.startAccessingSecurityScopedResource() else { return }
                    defer { url.stopAccessingSecurityScopedResource() }
                    viewModel.pdfData = try? Data(contentsOf: url)
                }
            }
            .task(id: selectedPhotoItem) {
                guard let item = selectedPhotoItem else { return }
                if let data = try? await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data),
                   let scaled = ImageHelper.downscaled(uiImage) {
                    viewModel.imageData = scaled
                }
            }
            .alert("Remove Photo?", isPresented: $showingRemoveImageAlert) {
                Button("Remove", role: .destructive) { viewModel.imageData = nil }
                Button("Cancel", role: .cancel) {}
            }
            .sheet(item: $addRelatedSheet) { sheet in
                switch sheet {
                case .room:
                    AddEditRoomView(room: nil, onCreated: { viewModel.selectedRoom = $0 })
                case .brand:
                    AddEditBrandView(brand: nil, onCreated: { viewModel.selectedBrand = $0 })
                case .category:
                    AddEditCategoryView(category: nil, onCreated: { viewModel.selectedCategory = $0 })
                case .owner:
                    AddEditOwnerView(owner: nil, onCreated: { viewModel.selectedOwner = $0 })
                }
            }
        }
    }

    // MARK: - Sections

    private var warrantySection: some View {
        Section("Warranty (months)") {
            Picker("Warranty", selection: $viewModel.warrantyMonths) {
                Text("None").tag(0)
                ForEach([6, 12, 24, 36, 48, 60], id: \.self) { months in
                    Text("\(months)").tag(months)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
        }
    }

    private var detailsSection: some View {
        Section("Item Details") {
            TextField("Name", text: $viewModel.name)
            TextField("Serial Number", text: $viewModel.serialNumber)
            HStack {
                Text("Price")
                Spacer()
                TextField(
                    "0.00",
                    value: $viewModel.price,
                    format: .number.precision(.fractionLength(2))
                )
                .multilineTextAlignment(.trailing)
                .keyboardType(.decimalPad)
            }
            TextField("Remarks", text: $viewModel.remark, axis: .vertical)
                .lineLimit(3, reservesSpace: true)
        }
    }

    private var photoSection: some View {
        Section("Photo") {
            if let data = viewModel.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 200)
                    .clipShape(.rect(cornerRadius: 8))
                Button("Remove Photo", role: .destructive) {
                    showingRemoveImageAlert = true
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

    private var documentSection: some View {
        Section("Document") {
            if viewModel.pdfData != nil {
                Label("PDF attached", systemImage: "doc.fill")
                    .foregroundStyle(.secondary)
                Button("Remove PDF", role: .destructive) {
                    viewModel.pdfData = nil
                }
            } else {
                Button("Attach PDF", systemImage: "doc.badge.plus") {
                    showingFilePicker = true
                }
            }
        }
    }

    private var classifySection: some View {
        Section("Classify") {
            Picker("Room", selection: $viewModel.selectedRoom) {
                Text("Select Room").tag(Optional<Room>.none)
                ForEach(rooms) { room in
                    Label(room.name, systemImage: room.sfSymbol).tag(Optional(room))
                }
            }
            addNewButton("Add New Room…") { addRelatedSheet = .room }
            Picker("Brand", selection: $viewModel.selectedBrand) {
                Text("Select Brand").tag(Optional<Brand>.none)
                ForEach(brands) { brand in
                    Label(brand.name, systemImage: brand.sfSymbol).tag(Optional(brand))
                }
            }
            addNewButton("Add New Brand…") { addRelatedSheet = .brand }
            Picker("Category", selection: $viewModel.selectedCategory) {
                Text("Select Category").tag(Optional<ItemCategory>.none)
                ForEach(categories) { category in
                    Label(category.name, systemImage: category.sfSymbol).tag(Optional(category))
                }
            }
            addNewButton("Add New Category…") { addRelatedSheet = .category }
            Picker("Owner", selection: $viewModel.selectedOwner) {
                Text("Select Owner").tag(Optional<Owner>.none)
                ForEach(owners) { owner in
                    Text(owner.name).tag(Optional(owner))
                }
            }
            addNewButton("Add New Owner…") { addRelatedSheet = .owner }
        }
    }

    private func addNewButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(title, systemImage: "plus", action: action)
            .buttonStyle(.glass)
            .font(.subheadline)
            .frame(maxWidth: .infinity)
            .listRowBackground(Color.clear)
    }
}
