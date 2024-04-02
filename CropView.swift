//
//  CropView.swift
//  PhotoGallery
//
//  Created by User on 21/05/2023.
//  Author: Dominika Rzepka
//
// Manage the cropping with the library TOCropViewController (names speeks for themselves)


import SwiftUI
import TOCropViewController

struct CropView: UIViewControllerRepresentable {
    let image: UIImage
    @Binding var croppedImage: UIImage?

    func makeUIViewController(context: UIViewControllerRepresentableContext<CropView>) -> TOCropViewController {
        let cropViewController = TOCropViewController(image: image)
        cropViewController.delegate = context.coordinator
        return cropViewController
    }

    func updateUIViewController(_ uiViewController: TOCropViewController, context: UIViewControllerRepresentableContext<CropView>) {
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(croppedImage: $croppedImage)
    }

    final class Coordinator: NSObject, TOCropViewControllerDelegate {
        @Binding var croppedImage: UIImage?

        init(croppedImage: Binding<UIImage?>) {
            _croppedImage = croppedImage
        }

        func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
            croppedImage = image
            cropViewController.dismiss(animated: true)
        }
        
        func cropViewControllerDidCancel(_ cropViewController: TOCropViewController) {
            croppedImage = nil
            cropViewController.dismiss(animated: true)
        }
    }
}



