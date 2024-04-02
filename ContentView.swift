//
//  ContentView.swift
//  PhotoGallery
//
//  Created by User on 14/05/2023.
//  Author: Dominika Rzepka
//

import SwiftUI
import PhotosUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct ContentView: View {
    @State private var showImagePicker = false
    @State private var showFullScreenImage = false
    @State private var selectedImages: [UIImage] = []
    
    @StateObject private var galleryViewModel = GalleryViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if galleryViewModel.photos.isEmpty {
                    Text("No Photos")
                        .font(.title)
                        .foregroundColor(.gray)
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))]) {
                            ForEach(galleryViewModel.photos, id: \.self) { photo in
                                Image(uiImage: photo)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(8)
                                    .onTapGesture { //when click show the full view
                                        showFullScreenImage.toggle()
                                    }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Gallery")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { //button for picking image
                         //because of the simulator I cannot use the camera
                         //unfortunately I do not have any iOS device, so image picker is all i can do here
                        showImagePicker.toggle()
                    }) {
                        Image(systemName: "camera")
                    }
                }
            }
        }
        .sheet(isPresented: $showImagePicker, onDismiss: { //show the sheet to pick image
            galleryViewModel.addPhotos(selectedImages)
            selectedImages.removeAll()
        }) {
            ImagePicker(selectedImages: $selectedImages, sourceType: getAvailableSourceType()).environmentObject(galleryViewModel)
        }
        .sheet(isPresented: $showFullScreenImage) { //show the sheet to present full photo view
            FullScreenImageView(selectedImages: galleryViewModel.photos)
                .environmentObject(galleryViewModel)
        }
        .onChange(of: galleryViewModel.updateTrigger) { _ in
            // Reload the grid view when the updateTrigger value changes
            galleryViewModel.updateTrigger.toggle()
        }
    }
    
    private func getAvailableSourceType() -> UIImagePickerController.SourceType { //checking if there is a possibility for runing camera, if not then show image picker
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            return .camera
        } else {
            return .photoLibrary
        }
    }
}
