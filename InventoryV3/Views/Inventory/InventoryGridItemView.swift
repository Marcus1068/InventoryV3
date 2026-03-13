//
//  InventoryGridItemView.swift
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

private struct ImageArea: View {
    let item: InventoryItem

    var body: some View {
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
}

private struct InfoArea: View {
    let item: InventoryItem

    var body: some View {
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

struct InventoryGridItemView: View {
    let item: InventoryItem

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ImageArea(item: item)
            InfoArea(item: item)
        }
        .clipShape(.rect(cornerRadius: 16))
        .glassEffect(.regular, in: .rect(cornerRadius: 16))
        #if !targetEnvironment(macCatalyst)
        .hoverEffect()
        #endif
    }
}
