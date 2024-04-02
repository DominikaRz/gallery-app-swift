//
//  ImagePicker.swift
//  PhotoGallery
//
//  Created by User on 21/05/2023.
//  Author: Dominika Rzepka.
//
// Manage the picker if camera is not avalable (names speeks for themselves)

import SwiftUI
import PhotosUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct ImagePicker: UIViewControllerRepresentable {
    typealias UIViewControllerType = PHPickerViewController

    @Binding var selectedImages: [UIImage]
    @EnvironmentObject var galleryViewModel: GalleryViewModel // Add this line
    var sourceType: UIImagePickerController.SourceType
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 0 // Set the desired maximum number of images (0 means no limit)
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(selectedImages: $selectedImages, galleryViewModel: galleryViewModel)
    }



    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        @Binding var selectedImages: [UIImage]
        let galleryViewModel: GalleryViewModel
        
        init(selectedImages: Binding<[UIImage]>, galleryViewModel: GalleryViewModel) {
            _selectedImages = selectedImages
            self.galleryViewModel = galleryViewModel
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            let group = DispatchGroup()
            var images: [UIImage] = []
            
            for result in results {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    group.enter()
                    
                    result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                        if let image = image as? UIImage {
                            images.append(image)
                        }
                        
                        group.leave()
                    }
                }
            }
            
            group.notify(queue: DispatchQueue.main) {
                self.galleryViewModel.addPhotos(images)
            }
            
            picker.dismiss(animated: true, completion: nil)
        }

    }
}

