//
//  ImageHelper.swift
//  InventoryV3
//
//  Created by Marcus Deuß on 09.03.26.
//

import UIKit

enum ImageHelper {
    /// Scales the longest side to ≤ maxDimension and returns JPEG data.
    static func downscaled(_ image: UIImage, maxDimension: CGFloat = 800) -> Data? {
        let size = image.size
        let longestSide = max(size.width, size.height)
        guard longestSide > maxDimension else {
            return image.jpegData(compressionQuality: 0.8)
        }

        let scale = maxDimension / longestSide
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)

        let renderer = UIGraphicsImageRenderer(size: newSize)
        let scaled = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        return scaled.jpegData(compressionQuality: 0.8)
    }
}
