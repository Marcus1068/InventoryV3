//
//  InventoryRoomSectionHeader.swift
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
