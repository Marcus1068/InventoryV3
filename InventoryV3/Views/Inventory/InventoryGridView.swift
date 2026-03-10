//
//  InventoryGridView.swift
//  InventoryV3
//
//  Created by Marcus Deuß on 09.03.26.
//

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
            }
        }
    }
}

#Preview {
    InventoryGridView()
        .modelContainer(for: InventoryItem.self, inMemory: true)
}
