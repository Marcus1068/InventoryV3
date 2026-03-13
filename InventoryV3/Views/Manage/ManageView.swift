//
//  ManageView.swift
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

enum ManageDestination: Hashable {
    case rooms, brands, categories, owners
}

struct ManageView: View {
    @State private var selectedDestination: ManageDestination? = .rooms

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedDestination) {
                Section("Locations") {
                    Label("Rooms", systemImage: "house")
                        .tag(ManageDestination.rooms)
                }
                Section("Catalog") {
                    Label("Brands", systemImage: "tag")
                        .tag(ManageDestination.brands)
                    Label("Categories", systemImage: "square.grid.2x2")
                        .tag(ManageDestination.categories)
                }
                Section("People") {
                    Label("Owners", systemImage: "person")
                        .tag(ManageDestination.owners)
                }
            }
            .navigationTitle("Manage")
        } detail: {
            switch selectedDestination {
            case .rooms:
                RoomsListView()
            case .brands:
                BrandsListView()
            case .categories:
                CategoriesListView()
            case .owners:
                OwnersListView()
            case nil:
                ContentUnavailableView("Select a Category", systemImage: "folder")
            }
        }
    }
}

#Preview {
    ManageView()
}
