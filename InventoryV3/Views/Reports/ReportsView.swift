//
//  ReportsView.swift
//  InventoryV3
//
//  Created by Marcus Deuß on 09.03.26.
//

import SwiftUI

struct ReportsView: View {
    var body: some View {
        ContentUnavailableView(
            "Reports Coming Soon",
            systemImage: "chart.bar",
            description: Text("Analytics and export features will appear here.")
        )
    }
}

#Preview {
    ReportsView()
}
