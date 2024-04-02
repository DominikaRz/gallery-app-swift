//
//  IUImageRotate.swift
//  PhotoGallery
//
//  Created by User on 21/05/2023.
//  Author: Dominika Rzepka
//

import SwiftUI

//change the UIImage for rotation
extension UIImage {
    func rotated(by degrees: Double) -> UIImage? {
        let radians = CGFloat(degrees * .pi / 180)
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: radians))
            .integral.size
        
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            context.translateBy(x: rotatedSize.width / 2.0, y: rotatedSize.height / 2.0)
            context.rotate(by: radians)
            
            // flip the image only if the rotation angle is not 0
            if degrees != 0 {
                context.scaleBy(x: 1.0, y: 1.0)
            }
            
            draw(in: CGRect(x: -size.width / 2.0, y: -size.height / 2.0, width: size.width, height: size.height))
            
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return rotatedImage
        }
        
        return nil
    }

}
