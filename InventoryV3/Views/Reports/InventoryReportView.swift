//
//  InventoryReportView.swift
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
import SwiftData

struct InventoryReportView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \InventoryItem.name) private var items: [InventoryItem]

    @State private var pdfURL: URL?
    @State private var isGenerating = false

    private static let pageWidth: CGFloat = 595   // A4 width in points

    var body: some View {
        NavigationStack {
            ScrollView {
                // Page shadow wrapper so the white report looks like a document
                InventoryReportContent(items: items)
                    .frame(maxWidth: .infinity)
                    .clipShape(.rect(cornerRadius: 4))
                    .shadow(color: .black.opacity(0.18), radius: 12, y: 4)
                    .padding()
            }
            .background(Color(red: 0.88, green: 0.89, blue: 0.92))
            .navigationTitle("Inventory Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    if isGenerating {
                        ProgressView()
                    } else if let url = pdfURL {
                        ShareLink(
                            item: url,
                            preview: SharePreview(
                                "Inventory Report",
                                image: Image(systemName: "doc.richtext.fill")
                            )
                        ) {
                            Label("Share PDF", systemImage: "square.and.arrow.up")
                        }
                    }
                }
            }
            .task {
                await buildPDF()
            }
        }
    }

    // MARK: - PDF generation

    @MainActor
    private func buildPDF() async {
        isGenerating = true
        defer { isGenerating = false }

        let content = InventoryReportContent(items: items)
            .frame(width: Self.pageWidth)

        let renderer = ImageRenderer(content: content)
        renderer.proposedSize = ProposedViewSize(width: Self.pageWidth, height: nil)
        renderer.scale = 2

        let filename = "InventoryReport-\(Date.now.formatted(.iso8601)).pdf"
            .replacing(":", with: "-")
            .replacing(" ", with: "_")
        let url = URL.temporaryDirectory.appending(path: filename)

        renderer.render { size, draw in
            var box = CGRect(origin: .zero, size: size)
            guard
                let consumer = CGDataConsumer(url: url as CFURL),
                let ctx = CGContext(consumer: consumer, mediaBox: &box, nil)
            else { return }
            ctx.beginPDFPage(nil)
            draw(ctx)
            ctx.endPDFPage()
            ctx.closePDF()
        }

        pdfURL = url
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: InventoryItem.self, configurations: config)
    SampleDataGenerator.generate(in: container.mainContext)
    return InventoryReportView()
        .modelContainer(container)
}
