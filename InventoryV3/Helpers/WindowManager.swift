//
//  WindowManager.swift
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


#if targetEnvironment(macCatalyst)
import UIKit

/// Manages Mac Catalyst window resizability and frame persistence.
///
/// Call `configureResizability()` immediately on appear to set size constraints.
/// Call `restoreFrame()` after a short delay so it runs after the system finishes
/// its own initial placement. Observe `UIScene.willDeactivateNotification` and
/// call `save()` in the handler — this notification fires on both window deactivation
/// and app quit (Cmd+Q), unlike `scenePhase == .inactive` which is skipped on quit.
enum WindowManager {

    // MARK: - Constants

    /// Smallest window size the user can drag to.
    static let minimumSize = CGSize(width: 900, height: 600)

    private static let frameKey = "com.inventoryv3.windowFrame"

    // MARK: - Public

    /// Sets min/max size restrictions. Safe to call immediately on appear.
    static func configureResizability() {
        guard let scene = firstScene else { return }
        scene.sizeRestrictions?.minimumSize = minimumSize
        scene.sizeRestrictions?.maximumSize = CGSize(
            width: CGFloat.greatestFiniteMagnitude,
            height: CGFloat.greatestFiniteMagnitude
        )
    }

    /// Applies the previously saved system frame.
    /// Must be called *after* the system has completed its own initial placement
    /// (use a short delay from `.task`).
    static func restoreFrame() {
        guard let scene = firstScene, let frame = savedFrame else { return }
        scene.requestGeometryUpdate(
            UIWindowScene.GeometryPreferences.Mac(systemFrame: frame)
        ) { _ in }
    }

    /// Persists the current window system frame to `UserDefaults`.
    /// Guards against saving a zero/stub frame that appears before the window
    /// has fully laid out.
    static func save() {
        guard let scene = firstScene else { return }
        let frame = scene.effectiveGeometry.systemFrame
        guard frame.size.width > 100, frame.size.height > 100 else { return }
        UserDefaults.standard.set(
            [frame.origin.x, frame.origin.y, frame.size.width, frame.size.height],
            forKey: frameKey
        )
    }

    // MARK: - Private

    /// Returns the first available window scene regardless of activation state,
    /// so geometry can be read/written during deactivation and background transitions.
    private static var firstScene: UIWindowScene? {
        UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first
    }

    private static var savedFrame: CGRect? {
        guard let vals = UserDefaults.standard.array(forKey: frameKey) as? [Double],
              vals.count == 4,
              vals[2] > 100, vals[3] > 100 else { return nil }
        return CGRect(x: vals[0], y: vals[1], width: vals[2], height: vals[3])
    }
}
#endif
