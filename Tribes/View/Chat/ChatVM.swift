//
//  ChatVM.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-20.
//

import Combine
import Foundation
import IdentifiedCollections
import SwiftUI

extension ChatView {
	@MainActor class ViewModel: ObservableObject {
		enum FocusField: Hashable {
			case text
		}
		
		let currentTribeMember: TribeMember
		private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
		
		var canChat: Bool {
			tribe.members.others.count > 0
		}
		
		var canSendText: Bool {
			!text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
		}
		
		var lastDraftId: MessageDraft.ID? {
			drafts.last?.id
		}
		
		var lastMessageId: Message.ID? {
			messages.last?.id
		}
		
		
		@Published var tribe: Tribe
		@Published var drafts: IdentifiedArrayOf<MessageDraft>
		@Published var messages: IdentifiedArrayOf<Message>
		@Published var isShowingMember: Bool = false
		@Published var memberToShow: TribeMember?
		@Published var text: String = ""
		
		//Clients
		let feedbackClient: FeedbackClient = FeedbackClient.shared
		let messageClient: MessageClient = MessageClient.shared
		
		init(tribe: Tribe) {
			let tribeMessage: TribeMessage? = messageClient.tribesMessages[id: tribe.id]
			self.currentTribeMember = tribe.members.currentMember ?? TribeMember.dummyTribeMember
			self.tribe = tribe
			self.drafts = tribeMessage?.chatDrafts ?? []
			self.messages = tribeMessage?.chat ?? []
			
			self.messageClient.$tribesMessages
				.sink(receiveValue: { tribeMessages in
					guard let messages = tribeMessages[id: tribe.id] else { return }
					self.drafts.forEach { draft in
						if let updatedDraft = messages.chatDrafts[id: draft.id] {
							self.drafts[id: draft.id] = updatedDraft
						} else {
							self.drafts.remove(id: draft.id)
						}
					}
					self.messages = messages.chat
				})
				.store(in: &cancellables)
			
			NotificationCenter
				.default.addObserver(
					self,
					selector: #selector(updateTribe),
					name: .tribesUpdated,
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
		
		func sendMessage() {
			guard canSendText else { return }
			let draft = MessageDraft(
				id: UUID(),
				content: .text(self.text),
				contextId: nil,
				caption: nil,
				tag: .chat,
				tribeId: tribe.id,
				timeStamp: Date.now
			)
			self.text = ""
			messageClient.postMessage(draft: draft)
			self.feedbackClient.medium()
		}
		
		@objc func updateTribe() {
			DispatchQueue.main.async {
				if let tribe = TribesRepository.shared.getTribe(tribeId: self.tribe.id) {
					self.tribe = tribe
				}
			}
		}
	}
}
