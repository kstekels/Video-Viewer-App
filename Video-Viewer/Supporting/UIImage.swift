//
//  UIImage.swift
//  Video-Viewer
//
//  Created by karlis.stekels on 22/04/2021.
//

import UIKit

extension UIImage {
    func resizedImage(with size: CGSize) -> UIImage?{
        // Create Graphics Context
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        // Draw Image in Graphics Context
        draw(in: CGRect(origin: .zero, size: size))
        
        // Create Image from Current Graphics Context
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // Clean Up Graphics Context
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
}
