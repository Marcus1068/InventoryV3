//
//  InventoryRoomSectionHeader.swift
//  InventoryV3
//
//  Created by Marcus Deuß on 09.03.26.
//

import SwiftUI

struct InventoryRoomSectionHeader: View {
    let room: Room?
    let itemCount: Int

    var body: some View {
        HStack(spacing: 10) {
            if let data = room?.photoData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 28, height: 28)
                    .clipShape(.circle)
            } else {
                Image(systemName: room?.sfSymbol ?? "house")
                    .foregroundStyle(.secondary)
            }
            Text(room?.name ?? "Unassigned")
                .bold()
            Spacer()
            Text("^[\(itemCount) item](inflect: true)")
                .foregroundStyle(.secondary)
                .font(.subheadline)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .glassEffect(.regular, in: .rect(cornerRadius: 12))
        .padding(.horizontal)
        .padding(.top, 8)
    }
}
