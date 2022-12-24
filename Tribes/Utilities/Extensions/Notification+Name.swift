//
//  Notification+Name.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-07-19.
//

import Foundation

extension Notification.Name {
	static let pushStack = Notification.Name("pushStack")
	static let popStack = Notification.Name("popStack")
	static let popToRoot = Notification.Name("popToRoot")
	static let updateAppState = Notification.Name("updateAppState")
}
