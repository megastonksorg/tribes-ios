//
//  ChatVM.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-20.
//

import Foundation
import SwiftUI

extension ChatView {
	@MainActor class ViewModel: ObservableObject {
		enum FocusField: Hashable {
			case text
		}
		
		var canSendText: Bool {
			!text.isEmpty
		}
		
		@Published var tribe: Tribe
		@Published var isShowingMember: Bool = false
		@Published var memberToShow: TribeMember?
		@Published var text: String = ""
		
		@Published var keyboardHeight: CGFloat = 0
		
		init(tribe: Tribe) {
			self.tribe = tribe
			
			//Listen for Keyboard Notifications
			NotificationCenter.default
				.addObserver(
					self,
					selector: #selector(setKeyboardHeight),
					name: UIResponder.keyboardWillShowNotification,
					object: nil
				)
			NotificationCenter.default
				.addObserver(
					self,
					selector: #selector(resetKeyboardHeight),
					name: UIResponder.keyboardWillHideNotification,
					object: nil
				)
		}
		
		func showTribeMemberCard(_ member: TribeMember) {
			withAnimation(Animation.cardViewAppear) {
				self.isShowingMember = true
				self.memberToShow = member
			}
		}
		
		func dismissTribeMemberCard() {
			withAnimation(Animation.cardViewDisappear) {
				self.isShowingMember = false
			}
			self.memberToShow = nil
		}
		
		@objc func setKeyboardHeight(notification: NSNotification) {
			guard let userInfo = notification.userInfo,
				 let keyboardRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
			else { return }
			DispatchQueue.main.async {
				self.keyboardHeight = keyboardRect.height + 12.0
			}
		}
		
		@objc func resetKeyboardHeight() {
			DispatchQueue.main.async {
				self.keyboardHeight = 0
			}
		}
	}
}
