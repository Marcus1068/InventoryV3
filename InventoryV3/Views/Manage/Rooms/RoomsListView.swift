//
//  RoomsListView.swift
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
