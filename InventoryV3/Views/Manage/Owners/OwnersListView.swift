//
//  OwnersListView.swift
//  InventoryV3
//
//  Created by Marcus Deuß on 09.03.26.
//

import SwiftUI
import SwiftData

struct OwnersListView: View {
    @Query(sort: \Owner.name) private var owners: [Owner]
    @Environment(\.modelContext) private var modelContext

    @State private var showingAddOwner = false
    @State private var editingOwner: Owner?

    var body: some View {
        List {
            ForEach(owners) { owner in
                Button {
                    editingOwner = owner
                } label: {
                    ownerLabel(owner)
                }
                .buttonStyle(.plain)
            }
            .onDelete { indexSet in
                for index in indexSet {
                    modelContext.delete(owners[index])
                }
            }
        }
        .navigationTitle("Owners")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
            ToolbarItem(placement: .primaryAction) {
                Button("Add Owner", systemImage: "plus") {
                    showingAddOwner = true
                }
            }
        }
        .sheet(isPresented: $showingAddOwner) {
            AddEditOwnerView(owner: nil)
        }
        .sheet(item: $editingOwner) { owner in
            AddEditOwnerView(owner: owner)
        }
        .overlay {
            if owners.isEmpty {
                ContentUnavailableView("No Owners", systemImage: "person",
                    description: Text("Tap + to add an owner."))
            }
        }
    }

    private func ownerLabel(_ owner: Owner) -> some View {
        HStack {
            if let data = owner.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 36, height: 36)
                    .clipShape(.circle)
            } else {
                Image(systemName: "person.circle")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
            Text(owner.name)
        }
    }
}

#Preview {
    OwnersListView()
        .modelContainer(for: Owner.self, inMemory: true)
}
