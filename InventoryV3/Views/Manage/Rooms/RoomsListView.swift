//
//  RoomsListView.swift
//  InventoryV3
//
//  Created by Marcus Deuß on 09.03.26.
//

import SwiftUI
import SwiftData

struct RoomsListView: View {
    @Query(sort: \Room.name) private var rooms: [Room]
    @Environment(\.modelContext) private var modelContext

    @State private var showingAddRoom = false
    @State private var editingRoom: Room?

    var body: some View {
        List {
            ForEach(rooms) { room in
                Button {
                    editingRoom = room
                } label: {
                    Label(room.name, systemImage: room.sfSymbol)
                }
                .buttonStyle(.plain)
            }
            .onDelete { indexSet in
                for index in indexSet {
                    modelContext.delete(rooms[index])
                }
            }
        }
        .navigationTitle("Rooms")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
            ToolbarItem(placement: .primaryAction) {
                Button("Add Room", systemImage: "plus") {
                    showingAddRoom = true
                }
            }
        }
        .sheet(isPresented: $showingAddRoom) {
            AddEditRoomView(room: nil)
        }
        .sheet(item: $editingRoom) { room in
            AddEditRoomView(room: room)
        }
        .overlay {
            if rooms.isEmpty {
                ContentUnavailableView("No Rooms", systemImage: "house",
                    description: Text("Tap + to add a room."))
            }
        }
    }
}

#Preview {
    RoomsListView()
        .modelContainer(for: Room.self, inMemory: true)
}
