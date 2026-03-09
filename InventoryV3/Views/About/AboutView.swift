//
//  AboutView.swift
//  InventoryV3
//
//  Created by Marcus Deuß on 09.03.26.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 16) {
                        Image(systemName: "shippingbox.fill")
                            .font(.system(size: 52))
                            .foregroundStyle(.tint)
                            .frame(width: 80, height: 80)
                            .glassEffect(.regular, in: .rect(cornerRadius: 18))
                        VStack(alignment: .leading) {
                            Text("InventoryV3")
                                .bold()
                                .font(.title3)
                            Text("Version \(Bundle.main.appVersion)")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Links") {
                    Link(destination: URL(string: "https://github.com/mdeuß/InventoryV3")!) {
                        Label("GitHub Repository", systemImage: "link")
                    }
                }

                Section("Legal") {
                    Text("© \(Date.now.formatted(.dateTime.year())) Marcus Deuß. All rights reserved.")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("About")
        }
    }
}

extension Bundle {
    var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}

#Preview {
    AboutView()
}
