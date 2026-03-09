//
//  InventoryGridItemView.swift
//  InventoryV3
//
//  Created by Marcus Deuß on 09.03.26.
//

import SwiftUI

struct InventoryGridItemView: View {
    let item: InventoryItem

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            imageArea
            infoArea
        }
        .clipShape(.rect(cornerRadius: 16))
        .glassEffect(.regular, in: .rect(cornerRadius: 16))
        #if !targetEnvironment(macCatalyst)
        .hoverEffect()
        #endif
    }

    private var imageArea: some View {
        Group {
            if let data = item.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else if let data = item.room?.photoData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .overlay(alignment: .bottomLeading) {
                        Label(item.room?.name ?? "", systemImage: item.room?.sfSymbol ?? "house")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .glassEffect(.regular, in: .capsule)
                            .padding(6)
                    }
            } else {
                Image(systemName: item.category?.sfSymbol ?? "square.grid.2x2")
                    .font(.system(size: 40))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 120)
        .clipped()
    }

    private var infoArea: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(item.name.isEmpty ? "Unnamed" : item.name)
                .bold()
                .lineLimit(1)
            Text(item.room?.name ?? "No Room")
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            Text(item.price, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(8)
    }
}
