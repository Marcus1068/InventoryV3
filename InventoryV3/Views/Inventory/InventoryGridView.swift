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

struct InventoryGridView: View {
    @Query(sort: \InventoryItem.name) private var items: [InventoryItem]
    @State private var searchText = ""
    @State private var showingAddItem = false

    private let columns = [GridItem(.adaptive(minimum: 160))]

    private var filteredItems: [InventoryItem] {
        guard !searchText.isEmpty else { return items }
        return items.filter { $0.name.localizedStandardContains(searchText) }
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
            Group {
                if filteredItems.isEmpty {
                    ContentUnavailableView(
                        searchText.isEmpty ? "No Items" : "No Results",
                        systemImage: "list.bullet.rectangle",
                        description: Text(searchText.isEmpty
                            ? "Tap + to add your first inventory item."
                            : "No items match \"\(searchText)\".")
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
