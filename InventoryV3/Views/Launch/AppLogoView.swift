//
//  AppLogoView.swift
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

/// Inventory warehouse-shelf logo mark.
/// Three shelf rows of small boxes — the bottom row intentionally not full,
/// suggesting active, ongoing inventory management.
struct AppLogoView: View {
    var size: CGFloat = 120

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.24)
                .fill(logoGradient)
                .frame(width: size, height: size)
                .shadow(color: Color(red: 0.18, green: 0.08, blue: 0.55).opacity(0.55), radius: size * 0.22, y: size * 0.10)

            VStack(spacing: size * 0.035) {
                shelfRow(filled: 4, of: 4)
                ShelfDivider(size: size)
                shelfRow(filled: 4, of: 4)
                ShelfDivider(size: size)
                shelfRow(filled: 3, of: 4)
            }
            .frame(width: size * 0.68, height: size * 0.66)
        }
    }

    // MARK: - Sub-views

    private func shelfRow(filled: Int, of total: Int) -> some View {
        HStack(spacing: size * 0.038) {
            ForEach(0..<total, id: \.self) { index in
                RoundedRectangle(cornerRadius: size * 0.034)
                    .fill(index < filled
                          ? Color.white
                          : Color.white.opacity(0.18))
                    .frame(width: size * 0.135, height: size * 0.148)
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Gradient

    private var logoGradient: LinearGradient {
        LinearGradient(
            stops: [
                .init(color: Color(red: 0.28, green: 0.12, blue: 0.72), location: 0),
                .init(color: Color(red: 0.05, green: 0.42, blue: 0.90), location: 1)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

private struct ShelfDivider: View {
    let size: CGFloat

    var body: some View {
        Capsule()
            .fill(Color.white.opacity(0.45))
            .frame(height: size * 0.018)
    }
}

#Preview {
    ZStack {
        Color(red: 0.10, green: 0.05, blue: 0.25).ignoresSafeArea()
        AppLogoView(size: 140)
    }
}
