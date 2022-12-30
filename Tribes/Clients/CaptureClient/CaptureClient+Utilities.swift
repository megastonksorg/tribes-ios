//
//  CaptureClient+Utilities.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-12-30.
//

import AVFoundation
import Foundation
import UIKit

enum CaptureValue {
	case previewImageBuffer(CMSampleBuffer?)
	case image(Int64, UIImage)
}

extension CaptureClient {
	static let context: CIContext = {
		if let device = MTLCreateSystemDefaultDevice() {
			return CIContext(mtlDevice: device)
		} else {
			return CIContext()
		}
	}()
}
