//
//  CategoriesListView.swift
//  InventoryV3
//
//  Created by Marcus Deuß on 09.03.26.
//

import SwiftUI
import SwiftData

struct CategoriesListView: View {
    @Query(sort: \ItemCategory.name) private var categories: [ItemCategory]
    @Environment(\.modelContext) private var modelContext

    @State private var showingAddCategory = false
    @State private var editingCategory: ItemCategory?

    var body: some View {
        List {
            ForEach(categories) { category in
                Button {
                    editingCategory = category
                } label: {
                    Label(category.name, systemImage: category.sfSymbol)
                }
                .buttonStyle(.plain)
            }
            .onDelete { indexSet in
                for index in indexSet {
                    modelContext.delete(categories[index])
                }
            }
        }
        .navigationTitle("Categories")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
            ToolbarItem(placement: .primaryAction) {
                Button("Add Category", systemImage: "plus") {
                    showingAddCategory = true
                }
            }
        }
        .sheet(isPresented: $showingAddCategory) {
            AddEditCategoryView(category: nil)
        }
        .sheet(item: $editingCategory) { category in
            AddEditCategoryView(category: category)
        }
        .overlay {
            if categories.isEmpty {
                ContentUnavailableView("No Categories", systemImage: "square.grid.2x2",
                    description: Text("Tap + to add a category."))
            }
        }
    }
}

#Preview {
    CategoriesListView()
        .modelContainer(for: ItemCategory.self, inMemory: true)
}
