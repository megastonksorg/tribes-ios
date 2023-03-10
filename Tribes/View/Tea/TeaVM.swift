//
//  TeaVM.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-12-30.
//

import Combine
import Foundation
import IdentifiedCollections
import SwiftUI

extension TeaView {
	@MainActor class ViewModel: ObservableObject {
		enum FocusField: Hashable {
			case text
		}
		
		let currentTribeMember: TribeMember
		let tribe: Tribe
		
		private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
		
		var canSendText: Bool {
			!text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
		}
		
		var isEmpty: Bool {
			tea.isEmpty && drafts.isEmpty
		}
		
		@Published var currentDraftId: MessageDraft.ID?
		@Published var currentTeaId: Message.ID?
		@Published var currentPill: Int = 0
		@Published var drafts: IdentifiedArrayOf<MessageDraft>
		@Published var tea: IdentifiedArrayOf<Message>
		@Published var text: String = ""
		
		var maxPills: Int {
			drafts.count + tea.count
		}
		
		var currentTeaTimeAgo: String? {
			guard let currentTeaId = currentTeaId else { return nil }
			if let currentTea = tea[id: currentTeaId] {
				return currentTea.timeStamp.timeAgoDisplay()
			}
			return nil
		}
		
		//Clients
		let messageClient: MessageClient = MessageClient.shared
		
		init(tribe: Tribe) {
			let drafts = messageClient.tribesMessages[id: tribe.id]?.teaDrafts ?? []
			let tea = messageClient.tribesMessages[id: tribe.id]?.tea ?? []
			self.currentTribeMember = tribe.members.currentMember ?? TribeMember.dummyTribeMember
			self.tribe = tribe
			self.drafts = drafts
			self.tea = tea
			
			setCurrentDraftOrTeaId(drafts: drafts, tea: tea)
			
			self.messageClient.$tribesMessages
				.sink(receiveValue: { tribeMessages in
					guard let messages = tribeMessages[id: tribe.id] else { return }
					messages.drafts.forEach { draftMessage in
						if self.drafts[id: draftMessage.id] != nil {
							self.drafts[id: draftMessage.id] = draftMessage
						}
					}
					messages.tea.forEach { teaMessage in
						if self.tea[id: teaMessage.id] != nil {
							self.tea[id: teaMessage.id] = teaMessage
						}
					}
				})
				.store(in: &cancellables)
		}
		
		private func setCurrentDraftOrTeaId(drafts: IdentifiedArrayOf<MessageDraft>, tea: IdentifiedArrayOf<Message>) {
			//Set the current draft or tea id. Drafts take precedence
			if !drafts.isEmpty {
				guard let firstDraftId = drafts.first?.id else { return }
				setCurrentDraftOrTeaId(draftId: firstDraftId, teaId: nil)
			} else if !tea.isEmpty {
				guard let firstTeaId = tea.first?.id else { return }
				setCurrentDraftOrTeaId(draftId: nil, teaId: firstTeaId)
			}
		}
		
		func setCurrentDraftOrTeaId(draftId: MessageDraft.ID?, teaId: Message.ID?) {
			//Only one can be set at a time
			if draftId != nil && teaId != nil {
				return
			}
			self.currentDraftId = draftId
			self.currentTeaId = teaId
		}
		
		func nextDraftOrTea() {
			let nextPill = currentPill + 1
			if nextPill < maxPills {
				self.currentPill = nextPill
			}
			//Navigate to the next draft
			if let currentDraftId = currentDraftId,
			   let currentDraftIndex = drafts.index(id: currentDraftId)
			{
				let nextDraftIndex: Int = currentDraftIndex + 1
				
				if nextDraftIndex < drafts.endIndex {
					//Return the next index
					setCurrentDraftOrTeaId(draftId: drafts[nextDraftIndex].id, teaId: nil)
					return
				}
				else {
					if !tea.isEmpty {
						//If the next index is invalid and there is tea to view, navigate to the first tea
						setCurrentDraftOrTeaId(draftId: nil, teaId: tea[0].id)
						return
					}
					return
				}
			}
			
			//Navigate to the next Tea
			if let currentTeaId = currentTeaId,
			   let currentTeaIndex = tea.index(id: currentTeaId)
			{
				let nextTeaIndex: Int = currentTeaIndex + 1
				
				if nextTeaIndex < tea.endIndex {
					//Return the next index
					setCurrentDraftOrTeaId(draftId: nil, teaId: tea[nextTeaIndex].id)
					return
				}
				else {
					if !drafts.isEmpty {
						//If the next index is invalid and there are drafts, navigate to the first draft
						setCurrentDraftOrTeaId(draftId: drafts[0].id, teaId: nil)
						return
					}
					return
				}
			}
		}
		
		func previousDraftOrTea() {
			let previousPill = currentPill - 1
			if previousPill >= 0 {
				self.currentPill = previousPill
			}
			//Navigate to the previous draft
			if let currentDraftId = currentDraftId,
			   let currentDraftIndex = drafts.index(id: currentDraftId)
			{
				let previousDraftIndex: Int = currentDraftIndex - 1
				
				if previousDraftIndex <= -1 {
					//If the previous index is invalid, do nothing
					return
				}
				else {
					//Return to the previous draft
					setCurrentDraftOrTeaId(draftId: drafts[previousDraftIndex].id, teaId: nil)
					return
				}
			}
			
			//Navigate to the previous Tea
			if let currentTeaId = currentTeaId,
			   let currentTeaIndex = tea.index(id: currentTeaId)
			{
				let previousTeaIndex = currentTeaIndex - 1
				
				if previousTeaIndex <= -1 {
					//If drafts is empty, then do nothing
					if drafts.isEmpty {
						return
					} else {
						guard let lastDraft = drafts.last else { return }
						setCurrentDraftOrTeaId(draftId: lastDraft.id, teaId: nil)
						return
					}
				} else {
					setCurrentDraftOrTeaId(draftId: nil, teaId: tea[previousTeaIndex].id)
				}
			}
		}
		
		func retryFailedDraft() {
			if let failedDraftId = currentDraftId {
				if let failedDraft = self.drafts[id: failedDraftId] {
					MessageClient.shared.postMessage(draft: failedDraft)
				}
			}
		}
	}
}
