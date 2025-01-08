//
//  UiImage+Extension.swift
//  Crypto Analyser
//
//  Created by IE15 on 04/01/25.
//

import Foundation
import UIKit

extension UIImage {
    
    // Resize the image while maintaining its aspect ratio
    func resized(to maxDimension: CGFloat) -> UIImage {
        let size = self.size
        let widthRatio = maxDimension / size.width
        let heightRatio = maxDimension / size.height

        // Determine the scale factor to maintain the aspect ratio
        let scaleFactor = min(widthRatio, heightRatio)
        
        // Calculate the new size
        let newSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)

        // Create a new image context and draw the image in the new size
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage ?? self
    }

    // Convert the image to a Base64 string
    func toBase64String(compressionQuality: CGFloat = 0.5, maxDimension: CGFloat = 800) -> String? {
        let resizedImage = self.resized(to: maxDimension)
        if let imageData = resizedImage.jpegData(compressionQuality: compressionQuality) {
            return imageData.base64EncodedString(options: .lineLength64Characters)
        }
        return nil
    }
}

extension String {
    func toImage() -> UIImage? {
        // Decode the Base64 string into Data
        guard let imageData = Data(base64Encoded: self, options: .ignoreUnknownCharacters) else {
            return nil
        }
        // Create a UIImage from the Data
        return UIImage(data: imageData)
    }
}
