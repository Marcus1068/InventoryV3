//
//  OwnersListView.swift
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
        .modelContainer(for: [InventoryItem.self, Room.self, Brand.self, ItemCategory.self, Owner.self], inMemory: true)
}
