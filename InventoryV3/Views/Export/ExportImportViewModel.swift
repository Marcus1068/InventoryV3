//
//  ExportImportViewModel.swift
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


import Foundation
import SwiftData

// MARK: - Import result

struct ImportResult {
    let imported: Int
    let skipped: Int
    let errors: [String]
}

// MARK: - View model

@Observable
final class ExportImportViewModel {

    var isExporting = false
    var csvContent: String?
    var isImporting = false
    var importResult: ImportResult?
    var importError: String?

    // MARK: - Export

    func exportCSV(items: [InventoryItem]) async {
        isExporting = true
        defer { isExporting = false }
        csvContent = buildCSV(from: items)
    }

    private func buildCSV(from items: [InventoryItem]) -> String {
        let header = "name,price,remark,serialNumber,warrantyMonths,dateAdded,roomName,brandName,categoryName,ownerName"
        let rows = items.map { item in
            [
                item.name,
                String(item.price),
                item.remark,
                item.serialNumber,
                String(item.warrantyMonths),
                item.dateAdded.formatted(.iso8601),
                item.room?.name     ?? "",
                item.brand?.name    ?? "",
                item.category?.name ?? "",
                item.owner?.name    ?? ""
            ]
            .map(csvEscape)
            .joined(separator: ",")
        }
        return ([header] + rows).joined(separator: "\n")
    }

    private func csvEscape(_ field: String) -> String {
        guard field.contains(",") || field.contains("\"") || field.contains("\n") else {
            return field
        }
        return "\"" + field.replacing("\"", with: "\"\"") + "\""
    }

    // MARK: - Import

    func importCSV(from url: URL, context: ModelContext) async {
        isImporting = true
        importResult = nil
        importError = nil
        defer { isImporting = false }

        let accessed = url.startAccessingSecurityScopedResource()
        defer { if accessed { url.stopAccessingSecurityScopedResource() } }

        guard let content = try? String(contentsOf: url, encoding: .utf8) else {
            importError = "Could not read the file. Make sure it is a valid UTF-8 CSV."
            return
        }

        importResult = parseAndInsert(csv: content, into: context)
    }

    private func parseAndInsert(csv: String, into context: ModelContext) -> ImportResult {
        // Normalise line endings and drop blank lines
        var lines = csv
            .replacing("\r\n", with: "\n")
            .replacing("\r",   with: "\n")
            .components(separatedBy: "\n")
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }

        guard !lines.isEmpty else {
            return ImportResult(imported: 0, skipped: 0, errors: ["File is empty."])
        }

        // Strip optional UTF-8 BOM
        if lines[0].hasPrefix("\u{FEFF}") {
            lines[0] = String(lines[0].dropFirst())
        }

        let header = parseCSVRow(lines.removeFirst())
            .map { $0.trimmingCharacters(in: .whitespaces) }

        guard let nameIdx = header.firstIndex(of: "name") else {
            return ImportResult(imported: 0, skipped: 0, errors: ["Missing required 'name' column in header."])
        }

        let priceIdx    = header.firstIndex(of: "price")
        let remarkIdx   = header.firstIndex(of: "remark")
        let serialIdx   = header.firstIndex(of: "serialNumber")
        let warrantyIdx = header.firstIndex(of: "warrantyMonths")
        let dateIdx     = header.firstIndex(of: "dateAdded")
        let roomIdx     = header.firstIndex(of: "roomName")
        let brandIdx    = header.firstIndex(of: "brandName")
        let categoryIdx = header.firstIndex(of: "categoryName")
        let ownerIdx    = header.firstIndex(of: "ownerName")

        // Pre-fetch existing related entities keyed by name to avoid duplicates
        let allRooms  = (try? context.fetch(FetchDescriptor<Room>()))         ?? []
        let allBrands = (try? context.fetch(FetchDescriptor<Brand>()))        ?? []
        let allCats   = (try? context.fetch(FetchDescriptor<ItemCategory>())) ?? []
        let allOwners = (try? context.fetch(FetchDescriptor<Owner>()))        ?? []

        var roomMap     = Dictionary(allRooms.map  { ($0.name, $0) }, uniquingKeysWith: { f, _ in f })
        var brandMap    = Dictionary(allBrands.map { ($0.name, $0) }, uniquingKeysWith: { f, _ in f })
        var categoryMap = Dictionary(allCats.map   { ($0.name, $0) }, uniquingKeysWith: { f, _ in f })
        var ownerMap    = Dictionary(allOwners.map { ($0.name, $0) }, uniquingKeysWith: { f, _ in f })

        // Build a dedup key set from all existing items.
        // Key: serial number if non-empty (globally unique), else name+room (case-insensitive).
        let existingItems = (try? context.fetch(FetchDescriptor<InventoryItem>())) ?? []
        var seen = Set(existingItems.map {
            dedupKey(name: $0.name, serialNumber: $0.serialNumber, roomName: $0.room?.name ?? "")
        })

        var imported = 0
        var skipped  = 0
        var errors: [String] = []

        for (offset, line) in lines.enumerated() {
            let fields = parseCSVRow(line)
            guard fields.count > nameIdx else {
                errors.append("Row \(offset + 2): too few columns, skipped.")
                continue
            }

            let rowName   = fields[nameIdx]
            let rowSerial = serialIdx.map { $0 < fields.count ? fields[$0] : "" } ?? ""
            let rowRoom   = roomIdx.map   { $0 < fields.count ? fields[$0] : "" } ?? ""
            let key = dedupKey(name: rowName, serialNumber: rowSerial, roomName: rowRoom)
            guard !seen.contains(key) else {
                skipped += 1
                continue
            }
            seen.insert(key)  // also deduplicate within this batch

            let item = InventoryItem()
            item.name = rowName

            if let idx = priceIdx,    idx < fields.count { item.price          = Double(fields[idx]) ?? 0 }
            if let idx = remarkIdx,   idx < fields.count { item.remark         = fields[idx] }
            if let idx = serialIdx,   idx < fields.count { item.serialNumber   = fields[idx] }
            if let idx = warrantyIdx, idx < fields.count { item.warrantyMonths = Int(fields[idx]) ?? 0 }
            if let idx = dateIdx, idx < fields.count, !fields[idx].isEmpty {
                item.dateAdded = (try? Date(fields[idx], strategy: .iso8601)) ?? .now
            }
            if let idx = roomIdx, idx < fields.count, !fields[idx].isEmpty {
                item.room = resolve(fields[idx], in: &roomMap, context: context) {
                    let r = Room(); r.name = $0; return r
                }
            }
            if let idx = brandIdx, idx < fields.count, !fields[idx].isEmpty {
                item.brand = resolve(fields[idx], in: &brandMap, context: context) {
                    let b = Brand(); b.name = $0; return b
                }
            }
            if let idx = categoryIdx, idx < fields.count, !fields[idx].isEmpty {
                item.category = resolve(fields[idx], in: &categoryMap, context: context) {
                    let c = ItemCategory(); c.name = $0; return c
                }
            }
            if let idx = ownerIdx, idx < fields.count, !fields[idx].isEmpty {
                item.owner = resolve(fields[idx], in: &ownerMap, context: context) {
                    let o = Owner(); o.name = $0; return o
                }
            }

            context.insert(item)
            imported += 1
        }

        return ImportResult(imported: imported, skipped: skipped, errors: errors)
    }

    /// Produces a stable deduplication key for an inventory item.
    /// Serial number (if present) is treated as a globally unique identifier;
    /// otherwise name + room are combined (case-insensitive).
    private func dedupKey(name: String, serialNumber: String, roomName: String) -> String {
        if !serialNumber.isEmpty {
            return "s:\(serialNumber.lowercased())"
        }
        return "n:\(name.lowercased())|r:\(roomName.lowercased())"
    }

    /// Returns an existing cached entity for `name`, or inserts and returns a new one.
    private func resolve<T: PersistentModel>(
        _ name: String,
        in map: inout [String: T],
        context: ModelContext,
        make: (String) -> T
    ) -> T {
        if let existing = map[name] { return existing }
        let new = make(name)
        context.insert(new)
        map[name] = new
        return new
    }

    // MARK: - RFC 4180 CSV row parser

    private func parseCSVRow(_ row: String) -> [String] {
        var fields: [String] = []
        var current = ""
        var inQuotes = false
        var idx = row.startIndex

        while idx < row.endIndex {
            let ch = row[idx]
            if inQuotes {
                if ch == "\"" {
                    let next = row.index(after: idx)
                    if next < row.endIndex && row[next] == "\"" {
                        current.append("\"")   // escaped double-quote
                        idx = row.index(after: next)
                        continue
                    }
                    inQuotes = false
                } else {
                    current.append(ch)
                }
            } else {
                switch ch {
                case "\"": inQuotes = true
                case ",":  fields.append(current); current = ""
                case "\r": break   // skip bare CR
                default:   current.append(ch)
                }
            }
            idx = row.index(after: idx)
        }
        fields.append(current)
        return fields
    }
}
