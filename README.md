# InventoryV3

A personal home inventory app for iOS built with SwiftUI, SwiftData, and CloudKit.

## Features

- **Inventory grid** — Browse all items in a room-grouped grid with photo cards
- **Item details** — Read-only detail view with full item info and an Edit button
- **Add / edit items** — Track name, price, serial number, warranty, remarks, photo, and PDF document
- **Classify items** — Assign each item to a Room, Brand, Category, and Owner; create new entries inline without leaving the form
- **Manage catalogue** — Dedicated CRUD views for Rooms (with photos), Brands, Categories, and Owners
- **iCloud sync** — All data syncs automatically via CloudKit across devices
- **Liquid Glass UI** — iOS 26 Liquid Glass styling throughout: glass grid cards, section headers, buttons, and navigation
- **Animated launch screen** — Custom warehouse-shelf logo with spring and fade animations
- **About view** — Animated floating logo with pulsing glow

## Requirements

| | Minimum |
|---|---|
| iOS | 26.0 |
| Xcode | 26.0 |
| Swift | 6.2 |

## Architecture

- **SwiftUI** — Declarative UI, `@Observable` view models, no UIKit
- **SwiftData** — Local persistence with CloudKit-compatible schema
- **CloudKit** — Automatic sync via `ModelConfiguration(cloudKitDatabase: .automatic)`
- **Swift 6 concurrency** — Strict concurrency, `@MainActor` default isolation, `.task(id:)` for safe async image loading

## Project Structure

```
InventoryV3/
├── Models/
│   ├── InventoryItem.swift
│   ├── Room.swift
│   ├── Brand.swift
│   ├── Category.swift          # ItemCategory (avoids ObjC name clash)
│   └── Owner.swift
├── Views/
│   ├── Inventory/
│   │   ├── InventoryGridView.swift
│   │   ├── InventoryGridItemView.swift
│   │   ├── InventoryRoomSectionHeader.swift
│   │   ├── InventoryDetailView.swift
│   │   └── AddEditInventoryView.swift
│   ├── Manage/
│   │   ├── ManageView.swift
│   │   ├── Rooms/
│   │   ├── Brands/
│   │   ├── Categories/
│   │   └── Owners/
│   ├── Launch/
│   │   ├── AppLogoView.swift
│   │   └── SplashScreenView.swift
│   ├── Reports/
│   │   └── ReportsView.swift
│   └── About/
│       ├── AboutView.swift
│       └── AboutLogoView.swift
├── Helpers/
│   ├── ImageHelper.swift       # JPEG downscaling (max 800 px)
│   ├── CameraPickerView.swift
│   └── SFSymbolPicker.swift
└── InventoryV3App.swift
```

## CloudKit Setup

Before running on a real device, enable iCloud in the project:

1. **Signing & Capabilities** → add **iCloud** capability → enable **CloudKit** → add container `iCloud.de.marcus-deuss.InventoryV3`
2. **Info.plist** → add `NSCameraUsageDescription` and `NSPhotoLibraryUsageDescription`

## Data Model

```
InventoryItem
 ├── name, price, serialNumber, warranty, remark
 ├── imageData (JPEG, max 800 px)
 ├── pdfData
 ├── dateAdded
 ├── room       → Room
 ├── brand      → Brand
 ├── category   → ItemCategory
 └── owner      → Owner

Room        — name, sfSymbol, photoData
Brand       — name, sfSymbol
ItemCategory — name, sfSymbol
Owner       — name, imageData
```

All relationships use `deleteRule: .nullify` and are optional, as required by CloudKit.

## License

© Marcus Deuß. All rights reserved.
