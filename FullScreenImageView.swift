//
//  FullScreenImageView.swift
//  PhotoGallery
//
//  Created by User on 20/05/2023.
//  Author: Dominika Rzepka
//

import SwiftUI
import TOCropViewController

struct FullScreenImageView: View {
    //basic variables
    @EnvironmentObject var galleryViewModel: GalleryViewModel //call gallery view
    @State private var originalImage: UIImage? //save original image for modify
    @State private var processedImage: UIImage? //before saving
    var selectedImages: [UIImage]? //selected images
    //var index: Int?
    @State private var currentIndex: Int = 0 //always show the first index

    //for filters
    @State private var filterIntensitySepia: Double = 0.0
    @State private var filterIntensityGrayscale: Double = 0.0
    
    private let context = CIContext() //initialize content
    private let filterS = CIFilter.sepiaTone() //sepia
    private let filterG = CIFilter.colorMonochrome() //grayscale
    
    //for showing exactly one editing tool
    @State private var isEditing = false
    @State private var isRotated = false
    @State private var isShowingRotation = false
    @State private var isShowingFilters = false
    @State private var isPresentingCropView = false
    
    //for editing tools
    @State private var rotationAngle: Double = 0
    @State private var croppedImage: UIImage?

    var body: some View {
        if let selectedImages = selectedImages, currentIndex >= 0, currentIndex < selectedImages.count {
            ZStack {
                Color.black.ignoresSafeArea() //black background

                VStack {
                    if let originalImage = originalImage {
                        Image(uiImage: processedImage ?? originalImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .rotationEffect(isRotated ? Angle(degrees: 90) : .zero)
                            .onTapGesture { //enable editing
                                isEditing.toggle()
                            }
                            .gesture( //move between photos
                                DragGesture(minimumDistance: 20)
                                    .onEnded { value in
                                        if value.translation.width < 0 {
                                            showNextImage() //next
                                        } else if value.translation.width > 0 {
                                            showPreviousImage() //previous
                                        }
                                    }
                            )
                        

                        if isEditing { //if there is editing 'mode'
                            VStack{
                                HStack {
                                    if !isShowingRotation{ //for applying filters
                                        Button(action: {
                                            isShowingFilters.toggle()
                                        }) {
                                            Image(systemName: "wand.and.stars")
                                                .foregroundColor(.white)
                                                .font(.title)
                                        }
                                        .padding()
                                    }
                                    if isShowingFilters {
                                        VStack {
                                            //sepia filter with slider to apply it
                                            Text("Sepia: ").foregroundColor(.white)
                                            Slider(value: $filterIntensitySepia, in: 0...1, step: 0.1)
                                                .padding()
                                                .onChange(of: filterIntensitySepia) { _ in
                                                    applyFilters()
                                                }
                                            //grayscale filter with slider to apply it
                                            Text("Grayscale: ").foregroundColor(.white)
                                            Slider(value: $filterIntensityGrayscale, in: 0...1, step: 0.1)
                                                .padding()
                                                .onChange(of: filterIntensityGrayscale) { _ in
                                                    applyFilters()
                                                }
                                            //for saving changes
                                            Button(action: {
                                                saveChanges()
                                            }) {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.white)
                                                    .font(.title)
                                            }
                                            .padding()
                                        }
                                    }
                                    if !isShowingFilters{ //rotaton view
                                        Button(action: {
                                            isShowingRotation.toggle()
                                        }) {
                                            Image(systemName: "arrow.triangle.2.circlepath")
                                                .foregroundColor(.white)
                                                .font(.title)
                                        }
                                        .padding()
                                    }
                                    if isShowingRotation {
                                        VStack {
                                            //rotation slider
                                            Slider(value: $rotationAngle, in: 0...360, step: 1)
                                                .padding()
                                                .onChange(of: rotationAngle) { _ in
                                                    applyRotation()
                                                }
                                            //rotate by 90 degrees
                                            Button(action: {
                                                rotateImageBy90Degrees()
                                            }) {
                                                Image(systemName: "arrow.counterclockwise.circle.fill")
                                                    .foregroundColor(.white)
                                                    .font(.title)
                                            }
                                            .padding()
                                            //for saving teh changes
                                            Button(action: {
                                                saveChanges()
                                            }) {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.white)
                                                    .font(.title)
                                            }
                                            .padding()
                                        }
                                    }
                                    if !isShowingFilters && !isShowingRotation{
                                        //cropping view
                                        Button(action: {
                                            isPresentingCropView.toggle()
                                        }) {
                                            Image(systemName: "crop")
                                                .foregroundColor(.white)
                                                .font(.title)
                                        }
                                        .padding()
                                        .sheet(isPresented: $isPresentingCropView) { //initialize the croping
                                        CropView(image: originalImage, croppedImage: $croppedImage)
                                            .onDisappear {
                                                if let croppedImage = croppedImage {
                                                    processedImage = croppedImage
                                                    self.originalImage = croppedImage
                                                    galleryViewModel.updatePhoto(at: currentIndex, with: croppedImage)
                                                    self.croppedImage = nil
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .onAppear {
                    currentIndex = selectedImages.firstIndex(of: selectedImages[currentIndex]) ?? 0
                    originalImage = selectedImages[currentIndex]  // assign original image
                    loadProcessedImage()
                    saveChanges()
                }
            }
        }
    }

    func loadProcessedImage() { //loading selected image
        if let selectedImages = selectedImages, currentIndex >= 0, currentIndex < selectedImages.count {
            processedImage = selectedImages[currentIndex]
        }
    }
    
    //applying filters (for both sliders to cooperate and change image in real time)
    func applyFilters() {
        guard let selectedImages = selectedImages, currentIndex >= 0, currentIndex < selectedImages.count else { return }
        var filteredImage = selectedImages[currentIndex]
        // apply sepia tone filter if intensity is greater than 0
        if filterIntensitySepia > 0 {
            filteredImage = applySepiaToneFilter(to: filteredImage, intensity: filterIntensitySepia) ?? filteredImage
        }
        // apply monochrome filter if intensity is greater than 0
        if filterIntensityGrayscale > 0 {
            filteredImage = applyColorMonochromeFilter(to: filteredImage, intensity: filterIntensityGrayscale) ?? filteredImage
        }
        processedImage = filteredImage
    }
    
    //apply the sepia
    func applySepiaToneFilter(to image: UIImage, intensity: Double) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }
        filterS.setValue(ciImage, forKey: kCIInputImageKey)
        filterS.setValue(intensity, forKey: kCIInputIntensityKey)
        
        guard let outputCIImage = filterS.outputImage else { return nil }
        guard let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else { return nil }
        return UIImage(cgImage: outputCGImage)
    }
    
    //apply the grayscale
    func applyColorMonochromeFilter(to image: UIImage, intensity: Double) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }
        filterG.setValue(ciImage, forKey: kCIInputImageKey)
        filterG.setValue(CIColor(red: 0.7, green: 0.7, blue: 0.7), forKey: kCIInputColorKey)
        filterG.setValue(intensity, forKey: kCIInputIntensityKey)
        
        guard let outputCIImage = filterG.outputImage else { return nil }
        guard let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else { return nil }
        return UIImage(cgImage: outputCGImage)
    }
    
    //rotation by 90 degrees (rotate button)
    func rotateImageBy90Degrees() {
        rotationAngle += 90.0
        applyRotation()
    }
    
    //applying rotation (slider)
    func applyRotation() {
        if let originalImage = originalImage {
            let rotatedImage = originalImage.rotated(by: rotationAngle)
            processedImage = rotatedImage
        }
    }

    //for saving changes (save buttons)
    func saveChanges() {
        if let processedImage = processedImage {
            galleryViewModel.updatePhoto(at: currentIndex, with: processedImage)
            originalImage = processedImage
        }
        
        isEditing = false
        isShowingFilters = false
        isShowingRotation = false
    }

    //showing the next image when slide (gesture)
    func showNextImage() {
        if let selectedImages = selectedImages {
            currentIndex = (currentIndex + 1) % selectedImages.count
            originalImage = selectedImages[currentIndex]
            processedImage = nil
            isRotated = false
            rotationAngle = 0
            isShowingFilters = false
            isShowingRotation = false
            loadProcessedImage()
        }
    }

    //showing the previous image when slide (gesture)
    func showPreviousImage() {
        if let selectedImages = selectedImages {
            currentIndex = (currentIndex - 1 + selectedImages.count) % selectedImages.count
            originalImage = selectedImages[currentIndex]
            processedImage = nil
            isRotated = false
            rotationAngle = 0
            isShowingFilters = false
            isShowingRotation = false
            loadProcessedImage()
        }
    }
}
