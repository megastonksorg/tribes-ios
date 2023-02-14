//
//  Helpers.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-05-15.
//

import AVFoundation
import Foundation
import SwiftUI

struct AppConstants {
	static let appName: String = "Tribes"
	static let email: String = "hello@megastonks.com"
	static let website: String = "tribesapp.ca"
	
	static let editIcon: String = "pencil.line"
	static let addressCopied: String = "Address copied to clipboard"
}

struct SizeConstants {
	static let cardInnerPadding: CGFloat = 4
	static let cornerRadius: CGFloat = 10
	static let fullNameLowerLimit: Int = 2
	static let fullNameHigherLimit: Int = 25
	static let videoFileType: AVFileType = AVFileType.mp4
	static let imagePixelSize: CGSize = CGSize(width: 1080, height: 1920)
	static let maxVideoRecordingDuration: Double = 20
	static let phraseGridSpacing: CGFloat = 10
	static let phraseGridCount: Int = 3
	static let pinLimit: Int = 6
	static let profileImageFrame: CGFloat = 150
	static let profileImageSize: CGSize = CGSize(width: 400, height: 400)
	static let subTitleSpacing: CGFloat = 50
	static let tribeNameLimit: Int = 24
	static let wordCornerRadius: CGFloat = 5.0
	static let wordSize: CGSize = CGSize(width: 100, height: 30)
}
