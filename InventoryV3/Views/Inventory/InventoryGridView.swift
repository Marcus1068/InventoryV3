//
//  InventoryGridView.swift
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

private struct RoomGroup: Identifiable {
    let room: Room?
    let items: [InventoryItem]
    var id: String { room?.name ?? "__unassigned__" }
}

// MARK: - Filter chip

private struct FilterChip: View {
    let label: String
    init(_ label: String, isSelected: Bool, action: @escaping () -> Void) {
        self.label = label
        self.isSelected = isSelected
        self.action = action
    }
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    isSelected ? Color.accentColor : Color.secondary.opacity(0.15),
                    in: .capsule
                )
                .foregroundStyle(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Filter bar (rooms + owners)

private struct InventoryFilterBar: View {
    let rooms: [Room]
    let owners: [Owner]
    @Binding var selectedRoom: Room?
    @Binding var selectedOwner: Owner?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if !rooms.isEmpty {
                ScrollView(.horizontal) {
                    HStack {
                        FilterChip("All Rooms", isSelected: selectedRoom == nil) {
                            selectedRoom = nil
                        }
                        ForEach(rooms) { room in
                            FilterChip(room.name, isSelected: selectedRoom == room) {
                                selectedRoom = selectedRoom == room ? nil : room
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                }
                .scrollIndicators(.hidden)
            }

            if !owners.isEmpty {
                ScrollView(.horizontal) {
                    HStack {
                        FilterChip("All Owners", isSelected: selectedOwner == nil) {
                            selectedOwner = nil
                        }
                        ForEach(owners) { owner in
                            FilterChip(owner.name, isSelected: selectedOwner == owner) {
                                selectedOwner = selectedOwner == owner ? nil : owner
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                }
                .scrollIndicators(.hidden)
            }

            Divider()
        }
    }
}

// MARK: - Item count banner

private struct ItemCountBanner: View {
    let total: Int
    let filtered: Int
    let isFiltered: Bool
    let filteredPrice: Double
    let totalPrice: Double

    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }

    var body: some View {
        HStack {
            if isFiltered {
                Text("\(filtered) of ^[\(total) item](inflect: true)")
            } else {
                Text("^[\(total) item](inflect: true)")
            }
            Text("·")
                .foregroundStyle(.tertiary)
            Text("Overall sum:")
            Text(isFiltered ? filteredPrice : totalPrice, format: .currency(code: currencyCode))
                .monospacedDigit()
            Spacer()
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .padding(.horizontal)
        .padding(.vertical, 6)
    }
}

// MARK: - Grid view

struct InventoryGridView: View {
    @Query(sort: \InventoryItem.name) private var items: [InventoryItem]
    @Query(sort: \Room.name)          private var rooms: [Room]
    @Query(sort: \Owner.name)         private var owners: [Owner]

    @State private var searchText   = ""
    @State private var selectedRoom: Room?  = nil
    @State private var selectedOwner: Owner? = nil
    @State private var showingAddItem = false

    private let columns = [GridItem(.adaptive(minimum: 160))]

    private var isFiltered: Bool {
        !searchText.isEmpty || selectedRoom != nil || selectedOwner != nil
    }

    private var filteredItems: [InventoryItem] {
        items.filter { item in
            let matchesSearch = searchText.isEmpty || item.name.localizedStandardContains(searchText)
            let matchesRoom   = selectedRoom  == nil || item.room  == selectedRoom
            let matchesOwner  = selectedOwner == nil || item.owner == selectedOwner
            return matchesSearch && matchesRoom && matchesOwner
        }
    }

    private var groupedItems: [RoomGroup] {
        let dict = Dictionary(grouping: filteredItems) { $0.room }
        return dict.sorted { a, b in
            switch (a.key?.name, b.key?.name) {
            case (let n1?, let n2?): return n1 < n2
            case (nil, _): return false
            case (_, nil): return true
            }
        }
        .map { RoomGroup(room: $0.key, items: $0.value) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if !rooms.isEmpty || !owners.isEmpty {
                    InventoryFilterBar(
                        rooms: rooms,
                        owners: owners,
                        selectedRoom: $selectedRoom,
                        selectedOwner: $selectedOwner
                    )
                }

                if !items.isEmpty {
                    ItemCountBanner(
                        total: items.count,
                        filtered: filteredItems.count,
                        isFiltered: isFiltered,
                        filteredPrice: filteredItems.reduce(0) { $0 + $1.price },
                        totalPrice: items.reduce(0) { $0 + $1.price }
                    )
                    Divider()
                }

                Group {
                    if filteredItems.isEmpty {
                        ContentUnavailableView(
                            isFiltered ? "No Results" : "No Items",
                            systemImage: "list.bullet.rectangle",
                            description: Text(isFiltered
                                ? "No items match the current filters."
                                : "Tap + to add your first inventory item.")
                        )
                    } else {
                        ScrollView {
                            GlassEffectContainer {
                                LazyVStack(pinnedViews: .sectionHeaders) {
                                    ForEach(groupedItems) { group in
                                        Section {
                                            LazyVGrid(columns: columns, spacing: 12) {
                                                ForEach(group.items) { item in
                                                    NavigationLink(value: item) {
                                                        InventoryGridItemView(item: item)
                                                    }
                                                    .buttonStyle(.plain)
                                                }
                                            }
                                            .padding(.horizontal)
                                            .padding(.bottom, 8)
                                        } header: {
                                            InventoryRoomSectionHeader(
                                                room: group.room,
                                                itemCount: group.items.count
                                            )
                                        }
                                    }
                                }
                                .padding(.bottom)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Inventory")
            .searchable(text: $searchText, prompt: "Search items")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add Item", systemImage: "plus") {
                        showingAddItem = true
                    }
                }
            }
            .navigationDestination(for: InventoryItem.self) { item in
                InventoryDetailView(item: item)
            }
            .sheet(isPresented: $showingAddItem) {
                AddEditInventoryView(item: nil)
                    .presentationSizing(.page)
            }
        }
    }
}

#Preview {
    InventoryGridView()
        .modelContainer(for: InventoryItem.self, inMemory: true)
}
