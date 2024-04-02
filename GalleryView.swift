//
//  GalleryView.swift
//  PhotoGallery
//
//  Created by User on 18/05/2023.
//  Author: Dominika Rzepka.
//

import SwiftUI
import PhotosUI
import CoreImage
import CoreImage.CIFilterBuiltins

class GalleryViewModel: ObservableObject {
    @Published var photos: [UIImage] = []
    @Published var updateTrigger: Bool = false
    
    //adding the photos to the list
    func addPhotos(_ newPhotos: [UIImage]) {
        DispatchQueue.main.async {
            self.photos.append(contentsOf: newPhotos)
            // Reload the grid view after appending new photos
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                windowScene.windows.first?.rootViewController?.view.setNeedsLayout()
            }
        }
    }

    //updating existing photos
    func updatePhoto(at index: Int, with image: UIImage) {
        guard index < photos.count else { return }
        photos[index] = image
    }

}
