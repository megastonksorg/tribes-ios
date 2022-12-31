//
//  CMSampleBuffer+ImageRepresentation.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-12-29.
//

import AVFoundation
import CoreImage
import UIKit

extension CMSampleBuffer {
	func image() -> UIImage? {
		guard let imageBuffer = CMSampleBufferGetImageBuffer(self) else { return .none }
		let ciimage = CIImage(cvImageBuffer: imageBuffer)

		let targetExtent = AVMakeRect(aspectRatio: SizeConstants.imagePixelSize, insideRect: ciimage.extent)

		guard let image = CaptureClient.context.createCGImage( ciimage, from: targetExtent) else { return nil }
		return UIImage(cgImage: image)
	}
}
