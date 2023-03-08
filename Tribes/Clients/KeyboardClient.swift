//
//  KeyboardClient.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-03-08.
//

import Foundation
import UIKit

@MainActor class KeyboardClient: ObservableObject {
	static let shared: KeyboardClient = KeyboardClient()
	
	@Published var keyboardHeight: CGFloat = 0
	
	init() {
		NotificationCenter.default
			.addObserver(
				self,
				selector: #selector(willShowKeyboard),
				name: UIResponder.keyboardWillShowNotification,
				object: nil
			)
		NotificationCenter.default
			.addObserver(
				self,
				selector: #selector(willHideKeyboard),
				name: UIResponder.keyboardWillHideNotification,
				object: nil
			)
	}
	
	@objc
	private func willShowKeyboard(notification: Notification) {
		if let userInfo = notification.userInfo,
			let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
			self.keyboardHeight = keyboardSize.height
		}
	}
	
	@objc
	private func willHideKeyboard(notification: Notification) {
		self.keyboardHeight = 0
	}
}
