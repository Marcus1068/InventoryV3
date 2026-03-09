//
//  SFSymbolPicker.swift
//  InventoryV3
//
//  Created by Marcus Deuß on 09.03.26.
//

import SwiftUI

struct SFSymbolPicker: View {
    @Binding var selection: String

    private let symbols = [
        "house", "house.fill", "bed.double", "sofa", "chair",
        "tv", "tv.fill", "desktopcomputer", "laptop.computer", "printer",
        "iphone", "ipad", "applewatch",
        "refrigerator", "oven", "microwave", "washer", "bathtub",
        "car", "bicycle", "scooter",
        "tag", "cart", "bag", "briefcase",
        "book", "photo.on.rectangle", "gamecontroller",
        "dumbbell", "fork.knife", "cup.and.saucer",
        "gift", "archivebox", "shippingbox",
        "hammer", "wrench.and.screwdriver", "paintbrush"
    ]

    private let columns = [GridItem(.adaptive(minimum: 56))]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(symbols, id: \.self) { symbol in
                    Button {
                        selection = symbol
                    } label: {
                        Image(systemName: symbol)
                            .font(.title2)
                            .frame(width: 48, height: 48)
                            .background(selection == symbol ? Color.accentColor : Color.secondary.opacity(0.15),
                                        in: .rect(cornerRadius: 10))
                            .foregroundStyle(selection == symbol ? .white : .primary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .navigationTitle("Choose Symbol")
        .navigationBarTitleDisplayMode(.inline)
    }
}
