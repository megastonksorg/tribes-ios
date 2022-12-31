//
//  CaptureClient+Utilities.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-12-30.
//

import AVFoundation
import Foundation
import UIKit

extension CaptureClient {
	enum CaptureValue {
		case previewImageBuffer(CMSampleBuffer?)
		case image(UIImage)
	}
	enum CaptureMode {
		case image
		case imageAndVideo
		case none
	}
	enum SessionSetupResult {
		case success
		case notAuthorized
		case configurationFailed
	}
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
