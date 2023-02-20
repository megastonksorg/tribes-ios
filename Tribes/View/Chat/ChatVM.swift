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
		
		@Published var tribe: Tribe
		@Published var isShowingMember: Bool = false
		@Published var memberToShow: TribeMember?
		@Published var text: String = ""
		
		var canSendText: Bool {
			!text.isEmpty
		}
		
		init(tribe: Tribe) {
			self.tribe = tribe
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
	}
}
