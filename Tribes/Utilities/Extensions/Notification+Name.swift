//
//  Notification+Name.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-07-19.
//

import Foundation

extension Notification.Name {
	static let captureClientRequestedAllVideoPlaybackPausing = Notification.Name("captureClientRequestedAllVideoPlaybackPausing")
	static let captureClientDidGrantPermissionForPlaybackResumption = Notification.Name("captureClientDidGrantPermissionForPlaybackResumption")
	static let toggleCompose = Notification.Name("toggleCompose")
	static let pushStack = Notification.Name("pushStack")
	static let popStack = Notification.Name("popStack")
	static let popToRoot = Notification.Name("popToRoot")
	static let updateAppState = Notification.Name("updateAppState")
	static let appInActive = Notification.Name("appInActive")
	static let userUpdated = Notification.Name("userUpdated")
}
