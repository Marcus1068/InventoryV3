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
import UIKit

struct InventoryReportView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \InventoryItem.name) private var items: [InventoryItem]

    @State private var pdfURL: URL?
    @State private var isGenerating = false

    @AppStorage("ownerName")    private var ownerName: String = ""
    @AppStorage("ownerAddress") private var ownerAddress: String = ""

    private static let pageWidth: CGFloat  = 595   // A4 width in points
    private static let pageHeight: CGFloat = 842   // A4 height in points

    var body: some View {
        NavigationStack {
            ScrollView {
                // Page shadow wrapper so the white report looks like a document
                InventoryReportContent(items: items, ownerName: ownerName, ownerAddress: ownerAddress)
                    .frame(maxWidth: .infinity)
                    .clipShape(.rect(cornerRadius: 4))
                    .shadow(color: .black.opacity(0.18), radius: 12, y: 4)
                    .padding()
            }
            .background(Color(red: 0.88, green: 0.89, blue: 0.92))
            .navigationTitle("Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
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
                                .labelStyle(.iconOnly)
                        }
                    }
                    Button("Done") { dismiss() }
                }
            }
            .task {
                await buildPDF()
            }
        }
    }

    // MARK: - PDF generation

    /// Returns the natural rendered height (in points) of a view at page width.
    @MainActor
    private func measuredHeight<V: View>(_ view: V) -> CGFloat {
        let r = ImageRenderer(content: view)
        r.proposedSize = ProposedViewSize(width: Self.pageWidth, height: nil)
        r.scale = 1
        return r.uiImage?.size.height ?? 56
    }

    @MainActor
    private func buildPDF() async {
        isGenerating = true
        defer { isGenerating = false }

        // Measure actual header/footer heights from their rendered images
        let headerHeight = measuredHeight(
            PDFPageHeader(items: items, pageIndex: 0, pageCount: 1).frame(width: Self.pageWidth)
        )
        let footerHeight = measuredHeight(
            PDFPageFooter(pageIndex: 0, pageCount: 1).frame(width: Self.pageWidth)
        )
        let gap: CGFloat = 10   // whitespace between header/footer and body
        let contentY = headerHeight + gap
        let contentHeight = Self.pageHeight - contentY - gap - footerHeight

        // Render body content (item rows only, no decorations)
        let bodyView = InventoryReportContent(items: items, showPageDecorations: false,
                                              ownerName: ownerName, ownerAddress: ownerAddress)
            .frame(width: Self.pageWidth)
        let bodyRenderer = ImageRenderer(content: bodyView)
        bodyRenderer.proposedSize = ProposedViewSize(width: Self.pageWidth, height: nil)
        bodyRenderer.scale = 2
        guard let bodyImage = bodyRenderer.uiImage else { return }

        let pageCount = max(1, Int(ceil(bodyImage.size.height / contentHeight)))

        // Pre-render per-page headers and footers
        let headerImages: [UIImage] = (0..<pageCount).compactMap { pageIndex in
            let view = PDFPageHeader(items: items, pageIndex: pageIndex, pageCount: pageCount)
                .frame(width: Self.pageWidth)
            let r = ImageRenderer(content: view)
            r.proposedSize = ProposedViewSize(width: Self.pageWidth, height: nil)
            r.scale = 2
            return r.uiImage
        }
        let footerImages: [UIImage] = (0..<pageCount).compactMap { pageIndex in
            let view = PDFPageFooter(pageIndex: pageIndex, pageCount: pageCount)
                .frame(width: Self.pageWidth)
            let r = ImageRenderer(content: view)
            r.proposedSize = ProposedViewSize(width: Self.pageWidth, height: nil)
            r.scale = 2
            return r.uiImage
        }

        let filename = "InventoryReport-\(Date.now.formatted(.iso8601)).pdf"
            .replacing(":", with: "-")
            .replacing(" ", with: "_")
        let url = URL.temporaryDirectory.appending(path: filename)

        let pageRect = CGRect(x: 0, y: 0, width: Self.pageWidth, height: Self.pageHeight)
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: pageRect)

        let data = pdfRenderer.pdfData { ctx in
            for pageIndex in 0..<pageCount {
                ctx.beginPage()

                // Per-page header
                if pageIndex < headerImages.count {
                    headerImages[pageIndex].draw(in: CGRect(x: 0, y: 0,
                                                            width: Self.pageWidth, height: headerHeight))
                }

                // Body slice, clipped to the content band (with gap above and below)
                let contentRect = CGRect(x: 0, y: contentY,
                                         width: Self.pageWidth, height: contentHeight)
                ctx.cgContext.saveGState()
                ctx.cgContext.clip(to: contentRect)
                bodyImage.draw(at: CGPoint(x: 0, y: contentY - CGFloat(pageIndex) * contentHeight))
                ctx.cgContext.restoreGState()

                // Per-page footer
                if pageIndex < footerImages.count {
                    footerImages[pageIndex].draw(in: CGRect(x: 0,
                                                            y: Self.pageHeight - footerHeight,
                                                            width: Self.pageWidth, height: footerHeight))
                }
            }
        }

        try? data.write(to: url)
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
