//
//  BrandsListView.swift
//  InventoryV3
//
//  Created by Marcus Deuß on 09.03.26.
//

import SwiftUI
import SwiftData

struct BrandsListView: View {
    @Query(sort: \Brand.name) private var brands: [Brand]
    @Environment(\.modelContext) private var modelContext

    @State private var showingAddBrand = false
    @State private var editingBrand: Brand?

    var body: some View {
        List {
            ForEach(brands) { brand in
                Button {
                    editingBrand = brand
                } label: {
                    Label(brand.name, systemImage: brand.sfSymbol)
                }
                .buttonStyle(.plain)
            }
            .onDelete { indexSet in
                for index in indexSet {
                    modelContext.delete(brands[index])
                }
            }
        }
        .navigationTitle("Brands")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
            ToolbarItem(placement: .primaryAction) {
                Button("Add Brand", systemImage: "plus") {
                    showingAddBrand = true
                }
            }
        }
        .sheet(isPresented: $showingAddBrand) {
            AddEditBrandView(brand: nil)
        }
        .sheet(item: $editingBrand) { brand in
            AddEditBrandView(brand: brand)
        }
        .overlay {
            if brands.isEmpty {
                ContentUnavailableView("No Brands", systemImage: "tag",
                    description: Text("Tap + to add a brand."))
            }
        }
    }
}

#Preview {
    BrandsListView()
        .modelContainer(for: Brand.self, inMemory: true)
}
