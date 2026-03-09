//
//  ManageView.swift
//  InventoryV3
//
//  Created by Marcus Deuß on 09.03.26.
//

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
