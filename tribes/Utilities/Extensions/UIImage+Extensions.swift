//
//  UIImage+Extensions.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-07-28.
//

import UIKit

extension UIImage {
	func resize(to newSize: CGSize) -> UIImage {
		return UIGraphicsImageRenderer(size: newSize).image { _ in
			let hScale = newSize.height / size.height
			let vScale = newSize.width / size.width
			let scale = max(hScale, vScale) // scaleToFill
			let resizeSize = CGSize(width: size.width*scale, height: size.height*scale)
			var middle = CGPoint.zero
			if resizeSize.width > newSize.width {
				middle.x -= (resizeSize.width-newSize.width)/2.0
			}
			if resizeSize.height > newSize.height {
				middle.y -= (resizeSize.height-newSize.height)/2.0
			}
			
			draw(in: CGRect(origin: middle, size: resizeSize))
		}
	}
	
	
	func resized(withPercentage percentage: CGFloat) -> UIImage? {
		let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
		UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
		defer { UIGraphicsEndImageContext() }
		draw(in: CGRect(origin: .zero, size: canvasSize))
		return UIGraphicsGetImageFromCurrentImageContext()
	}
	
	func resizedTo(megaBytes: Double) -> UIImage? {
		guard let imageData = self.pngData() else { return nil }
		let scale = megaBytes * 1024.0
		
		var resizingImage = self
		var imageSizeKB = Double(imageData.count) / scale
		
		while imageSizeKB > scale {
			guard let resizedImage = resizingImage.resized(withPercentage: 0.5),
				  let imageData = resizedImage.pngData() else { return nil }
			
			resizingImage = resizedImage
			imageSizeKB = Double(imageData.count) / scale
		}
		
		return resizingImage
	}
	
	func croppedAndScaled(toFill targetSize: CGSize) -> UIImage {
		let scale = max(targetSize.width / size.width, targetSize.height / size.height)
		let scaledSize = CGSize(width: size.width * scale, height: size.height * scale)
		
		let adjustedOrigin: CGPoint
		if scaledSize.width > targetSize.width {
			adjustedOrigin = CGPoint(x: -((scaledSize.width - targetSize.width) / 2), y: 0)
		} else {
			adjustedOrigin = CGPoint(x: 0, y: -((scaledSize.height - targetSize.height) / 2))
		}
		
		let format = UIGraphicsImageRendererFormat()
		format.scale = 1
		return UIGraphicsImageRenderer(size: targetSize, format: format).image { context in
			draw(in: CGRect(origin: adjustedOrigin, size: scaledSize))
		}
	}
}
