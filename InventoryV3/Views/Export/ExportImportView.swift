//
//  ExportImportView.swift
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
import UniformTypeIdentifiers

// MARK: - CSV FileDocument

/// A `FileDocument` that wraps CSV text so `fileExporter` saves a proper
/// `.csv` file on both iOS and macOS rather than sharing a plain-text URL.
struct CSVDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.commaSeparatedText, .plainText] }

    var content: String

    init(content: String = "") {
        self.content = content
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        content = string
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: Data(content.utf8))
    }
}

// MARK: - Export section

private struct ExportSection: View {
    let items: [InventoryItem]
    let viewModel: ExportImportViewModel
    @Binding var showingExporter: Bool

    var body: some View {
        Section {
            if viewModel.isExporting {
                HStack {
                    ProgressView()
                    Text("Generating CSV…")
                        .foregroundStyle(.secondary)
                }
            } else if viewModel.csvContent != nil {
                Button {
                    showingExporter = true
                } label: {
                    Label("Save / Share CSV", systemImage: "square.and.arrow.up")
                }
                Button("Regenerate") {
                    Task { await viewModel.exportCSV(items: items) }
                }
                .foregroundStyle(.secondary)
            } else {
                Button {
                    Task {
                        await viewModel.exportCSV(items: items)
                        showingExporter = true
                    }
                } label: {
                    Label("Export to CSV", systemImage: "arrow.up.doc")
                }
                .disabled(items.isEmpty)
            }
        } header: {
            Label("Export", systemImage: "arrow.up.doc")
        } footer: {
            Text("Exports all ^[\(items.count) item](inflect: true) to a CSV file. Photos and attached documents are not included.")
        }
    }
}

// MARK: - Import section

private struct ImportSection: View {
    let viewModel: ExportImportViewModel
    @Binding var showingImporter: Bool

    var body: some View {
        Section {
            if viewModel.isImporting {
                HStack {
                    ProgressView()
                    Text("Importing…")
                        .foregroundStyle(.secondary)
                }
            } else {
                Button {
                    viewModel.importResult = nil
                    viewModel.importError  = nil
                    showingImporter = true
                } label: {
                    Label("Import from CSV", systemImage: "arrow.down.doc")
                }
            }

            if let result = viewModel.importResult {
                Label(
                    "^[\(result.imported) item](inflect: true) imported",
                    systemImage: "checkmark.circle"
                )
                .foregroundStyle(.green)

                if result.skipped > 0 {
                    Label(
                        "^[\(result.skipped) duplicate](inflect: true) skipped",
                        systemImage: "minus.circle"
                    )
                    .foregroundStyle(.secondary)
                }

                ForEach(result.errors, id: \.self) { error in
                    Label(error, systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.orange)
                        .font(.caption)
                }
            }

            if let error = viewModel.importError {
                Label(error, systemImage: "xmark.circle")
                    .foregroundStyle(.red)
            }
        } header: {
            Label("Import", systemImage: "arrow.down.doc")
        } footer: {
            Text("Imports items from a CSV file. Rooms, brands, categories, and owners are matched by name — or created automatically if they don't exist yet.")
        }
    }
}

// MARK: - Format reference section

private struct FormatReferenceSection: View {
    var body: some View {
        Section {
            VStack(alignment: .leading) {
                Text("name,price,remark,serialNumber,warrantyMonths,dateAdded,roomName,brandName,categoryName,ownerName")
                    .font(.caption)
                    .monospaced()
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
            }
        } header: {
            Label("CSV Column Order", systemImage: "tablecells")
        } footer: {
            Text("Only 'name' is required. Omit columns you don't need. Dates use ISO 8601 format.")
        }
    }
}

// MARK: - Main view

struct ExportImportView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \InventoryItem.name) private var items: [InventoryItem]

    @State private var viewModel = ExportImportViewModel()
    @State private var showingImporter = false
    @State private var showingExporter = false

    var body: some View {
        NavigationStack {
            Form {
                ExportSection(items: items, viewModel: viewModel, showingExporter: $showingExporter)
                ImportSection(viewModel: viewModel, showingImporter: $showingImporter)
                FormatReferenceSection()
            }
            .navigationTitle("Export & Import")
            .fileExporter(
                isPresented: $showingExporter,
                document: CSVDocument(content: viewModel.csvContent ?? ""),
                contentType: .commaSeparatedText,
                defaultFilename: "Inventory"
            ) { _ in }
            .fileImporter(
                isPresented: $showingImporter,
                allowedContentTypes: [.commaSeparatedText, .plainText],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    guard let url = urls.first else { return }
                    Task {
                        await viewModel.importCSV(from: url, context: modelContext)
                    }
                case .failure:
                    viewModel.importError = "Failed to open the file."
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: InventoryItem.self, configurations: config)
    SampleDataGenerator.generate(in: container.mainContext)
    return ExportImportView()
        .modelContainer(container)
}
