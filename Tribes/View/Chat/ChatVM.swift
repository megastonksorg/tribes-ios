//
//  ChatVM.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-20.
//

import Combine
import Foundation
import SwiftUI

extension ChatView {
	@MainActor class ViewModel: ObservableObject {
		enum FocusField: Hashable {
			case text
		}
		
		var tribesRepositoryListener: TribesRepositoryListener = TribesRepositoryListener()
		
		private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
		
		var canSendText: Bool {
			!text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
		}
		
		@Published var tribe: Tribe
		@Published var isShowingMember: Bool = false
		@Published var memberToShow: TribeMember?
		@Published var text: String = ""
		
		init(tribe: Tribe) {
			self.tribe = tribe
			tribesRepositoryListener.repositoryUpdated = { tribes in
				if let tribe = tribes[id: tribe.id] {
					self.tribe = tribe
				}
			}
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
