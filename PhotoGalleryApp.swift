//
//  PhotoGalleryApp.swift
//  PhotoGallery
//
//  Created by User on 14/05/2023.
//  Author: Dominika Rzepka.
//
// Gallery app with some functionalities:
// 1. taking photo (only on real device, emulator is not supporting the function) or if camera is not possible t use picking multiple photos form existion ones by clicking the camera button on the top toolbar
// 2. Showing the grid of selected/taked photos
// 3. Showing the full view of the photos
// 4. Edit photo by clicking on image in full view:
//      - by clicking wand (first button from left) the sliders for applying filters (sepia and grayscale) will be visible. They will change the photo in real time. By clicking 'tick' button the changes are saved, and by clicking on 'wand' button we return to choose editing;
//      - by clicking on rotation button (middle one) the rotation menager will appear. There is slider for rotation 'by hand' and special button with arrow below it that will rotate the image by 90 degrees. When clicked on 'tick' button the changes are saved, by clicking on rotate button we go back to previous view;
//      -the last button allow to crop and also rotate the image. When clicked the next screen will appear. We can change the size of the photo by dragging the corners of the image. The first button with text "Cancel" leaves screen and go back without changes. Next button will rotate the image to the left. Third button will set image to original one, that means the changes will be removed. Next button will apply resolutions to photo. Next will rotate image to the right. The last one will save the picture and go back to the edit view;
//  To close the editing we tap on photo. There is possibility to move between photos by dragging (swiping) to the right or left.
//  To close full view we drag the screen to buttom.



import SwiftUI

@main
struct PhotoGalleryApp: App {
    var body: some Scene {
        WindowGroup {
            //calling the grid function with elements to manipulate gallery content
            ContentView()
                .environmentObject(GalleryViewModel())
        }
    }
}



