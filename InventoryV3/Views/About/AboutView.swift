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
                    AboutLogoView()
                }
                .listRowBackground(Color.clear)

                Section("Links") {
                    Link(destination: URL(string: "https://github.com/Marcus1068/InventoryV3")!) {
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
