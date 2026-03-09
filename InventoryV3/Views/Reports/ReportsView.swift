//
//  ReportsView.swift
//  InventoryV3
//
//  Created by Marcus Deuß on 09.03.26.
//

import SwiftUI

struct ReportsView: View {
    @State private var showingReport = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        showingReport = true
                    } label: {
                        HStack(spacing: 16) {
                            Image(systemName: "doc.richtext.fill")
                                .font(.title2)
                                .foregroundStyle(.white)
                                .frame(width: 48, height: 48)
                                .background(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.22, green: 0.10, blue: 0.60),
                                            Color(red: 0.05, green: 0.32, blue: 0.78)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(.rect(cornerRadius: 12))

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Inventory Report")
                                    .bold()
                                Text("Full list with photos, prices and warranty")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.tertiary)
                                .font(.caption)
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Reports")
            .sheet(isPresented: $showingReport) {
                InventoryReportView()
            }
        }
    }
}

#Preview {
    ReportsView()
}
