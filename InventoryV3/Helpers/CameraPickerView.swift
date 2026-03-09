//
//  CameraPickerView.swift
//  InventoryV3
//
//  Created by Marcus Deuß on 09.03.26.
//

#if !targetEnvironment(macCatalyst)
import SwiftUI
import UIKit

struct CameraPickerView: UIViewControllerRepresentable {
    let onImageSelected: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeCoordinator() -> Coordinator {
        Coordinator(dismiss: dismiss, onImageSelected: onImageSelected)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        private let dismiss: DismissAction
        private let onImageSelected: (UIImage) -> Void

        init(dismiss: DismissAction, onImageSelected: @escaping (UIImage) -> Void) {
            self.dismiss = dismiss
            self.onImageSelected = onImageSelected
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                onImageSelected(image)
            }
            dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss()
        }
    }
}
#endif
