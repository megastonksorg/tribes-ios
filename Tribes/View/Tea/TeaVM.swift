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
		
		struct TeaViewer: Identifiable {
			let id: Message.ID
			let viewers: [TribeMember.ID]
		}
		
		let currentTribeMember: TribeMember
		let tribe: Tribe
		
		private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
		
		var isHintTextHintVisible: Bool {
			text.isEmpty
		}
		
		var canSendText: Bool {
			!text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
		}
		
		var isEmpty: Bool {
			tea.isEmpty && drafts.isEmpty
		}
		
		var currentTea: Message? {
			guard
				let currentTeaId = currentTeaId,
				let currentTea = tea[id: currentTeaId]
			else { return nil }
			return currentTea
		}
		
		var currentTeaViewersIds: [TribeMember.ID] {
			if let currentTeaId = currentTeaId {
				return teaViewers[id: currentTeaId]?.viewers ?? []
			}
			return []
		}
		
		var isAuthorOfCurrentTea: Bool {
			guard
				let currentTea = currentTea,
				currentTea.senderId == currentTribeMember.id
			else { return false }
			
			return true
		}
		
		var currentContentType: Message.Body.Content.`Type`? {
			if let currentTea = currentTea {
				return currentTea.encryptedBody.content.outgoingType
			}
			if let currentDraftId = currentDraftId {
				return drafts[id: currentDraftId]?.content.outgoingType
			}
			return nil
		}
		
		var draftAndTeaIds: [String] {
			var allIds: [String] = drafts.map { $0.id.uuidString }
			let teaIds: [String] = tea.map { $0.id }
			allIds.append(contentsOf: teaIds)
			return allIds
		}
		
		@Published var currentDraftId: MessageDraft.ID?
		@Published var currentTeaId: Message.ID?
		@Published var currentPill: Int = 0
		@Published var drafts: IdentifiedArrayOf<MessageDraft>
		@Published var tea: IdentifiedArrayOf<Message>
		@Published var teaViewers: IdentifiedArrayOf<TeaViewer> = []
		@Published var readTea: MessageClient.ReadTea
		@Published var text: String = ""
		@Published var isShowingCurrentViewers: Bool = false
		
		//Clients
		let apiClient: APIClient = APIClient.shared
		let feedbackClient: FeedbackClient = FeedbackClient.shared
		let messageClient: MessageClient = MessageClient.shared
		
		init(tribe: Tribe) {
			let drafts = messageClient.tribesMessages[id: tribe.id]?.teaDrafts ?? []
			let tea = messageClient.tribesMessages[id: tribe.id]?.tea ?? []
			self.currentTribeMember = tribe.members.currentMember ?? TribeMember.dummyTribeMember
			self.tribe = tribe
			self.drafts = drafts
			self.tea = tea
			self.readTea = messageClient.readTea
			
			self.setCurrentDraftOrTeaId()
			
			self.messageClient.$readTea
				.sink { value in
					self.readTea = value
				}
				.store(in: &cancellables)
			
			NotificationCenter
				.default.addObserver(
					self,
					selector: #selector(updateMessage),
					name: .messageUpdated,
					object: nil
				)
		}
		
		func setCurrentDraftOrTeaId() {
			self.isShowingCurrentViewers = false
			DispatchQueue.main.async {
				if !self.draftAndTeaIds.isEmpty {
					let id: String = self.draftAndTeaIds[self.currentPill]
					//Set Draft
					if let draftId = UUID(uuidString: id),
						self.drafts[id: draftId] != nil {
						self.currentDraftId = draftId
						self.currentTeaId = nil
						return
					}
					
					//Set Tea
					if self.tea[id: id] != nil {
						self.currentDraftId = nil
						self.currentTeaId = id
						self.markTeaAsViewed()
						return
					}
				}
			}
			Task {
				if !self.draftAndTeaIds.isEmpty {
					let id: String = self.draftAndTeaIds[self.currentPill]
					//Do nothing if it is a draft
					if let draftId = UUID(uuidString: id),
					   self.drafts[id: draftId] != nil {
						return
					}
					
					//Mark the tea as read
					if let tea = self.tea[id: id] {
						if await !tea.isTeaRead {
							self.messageClient.markMessageAsRead(tea.id)
						}
					}
				}
			}
		}
		
		func nextDraftOrTea() {
			let nextPill = currentPill + 1
			
			guard nextPill < self.draftAndTeaIds.count else {
				setCurrentDraftOrTeaId()
				return
			}
			
			self.currentPill = nextPill
			setCurrentDraftOrTeaId()
		}
		
		func previousDraftOrTea() {
			let previousPill = currentPill - 1
			
			guard previousPill >= 0 else {
				setCurrentDraftOrTeaId()
				return
			}
			
			self.currentPill = previousPill
			setCurrentDraftOrTeaId()
		}
		
		func retryFailedDraft() {
			if let failedDraftId = currentDraftId {
				if let failedDraft = self.drafts[id: failedDraftId] {
					self.messageClient.postMessage(draft: failedDraft)
				}
			}
		}
		
		func deleteDraft() {
			if let draftId = currentDraftId {
				if let draft = self.drafts[id: draftId] {
					self.messageClient.deleteDraft(draft)
				}
			}
		}
		
		func deleteMessage() {
			if let currentTea = currentTea {
				self.messageClient.deleteMessage(currentTea, tribeId: self.tribe.id)
			}
		}
		
		func sendMessage() {
			let text = self.text.trimmingCharacters(in: .whitespacesAndNewlines)
			guard
				!text.isEmpty,
				let currentTeaId = self.currentTeaId
			else { return }
			
			let draft: MessageDraft = MessageDraft(
				id: UUID(),
				content: .text(text),
				contextId: currentTeaId,
				caption: nil,
				tag: .chat,
				tribeId: tribe.id,
				timeStamp: Date.now
			)
			
			self.text = ""
			messageClient.postMessage(draft: draft)
			self.feedbackClient.medium()
		}
		
		func isDraftOrTeaRead(pillIndex: Int) -> Bool {
			if !self.draftAndTeaIds.isEmpty {
				let id: String = self.draftAndTeaIds[pillIndex]
				//Return true if it is a draft
				if let draftId = UUID(uuidString: id),
				   self.drafts[id: draftId] != nil {
					return true
				}
				
				//Return the message read state
				if let tea = self.tea[id: id] {
					return self.readTea.contains(tea.id)
				}
			}
			return false
		}
		
		func markTeaAsViewed() {
			guard let currentTeaId = self.currentTeaId else { return }
			if !currentTeaViewersIds.contains(self.currentTribeMember.id) {
				self.apiClient
					.markMessageAsViewed(messageId: currentTeaId)
					.sink(
						receiveCompletion: { _ in },
						receiveValue: { _ in }
					)
					.store(in: &self.cancellables)
			}
		}
		
		func toggleViewers() {
			self.isShowingCurrentViewers.toggle()
			feedbackClient.light()
			guard let currentTea = self.currentTea else { return }
			if teaViewers[id: currentTea.id] == nil {
				self.apiClient
					.getMessageViewers(messageId: currentTea.id)
					.receive(on: DispatchQueue.main)
					.sink(
						receiveCompletion: { _ in },
						receiveValue: { walletAddresses in
							var uniqueWalletAddresses = Set(walletAddresses)
							uniqueWalletAddresses.remove(self.currentTribeMember.id)
							self.teaViewers.updateOrAppend(
								TeaViewer(
									id: currentTea.id,
									viewers: uniqueWalletAddresses.map { TribeMember.ID($0) }
								)
							)
						}
					)
					.store(in: &self.cancellables)
			}
		}
		
		private func updateCurrentDraftOrTeaId() {
			if self.currentPill == self.draftAndTeaIds.count - 1 {
				let previousIndex = self.currentPill - 1
				if self.draftAndTeaIds.indices.contains(previousIndex) {
					self.currentPill = previousIndex
					self.setCurrentDraftOrTeaId()
				}
			} else {
				self.setCurrentDraftOrTeaId()
			}
		}
		
		@objc private func updateMessage(notification: NSNotification) {
			if let dict = notification.userInfo as? NSDictionary {
				if let updateNotification = dict[AppConstants.messageNotificationDictionaryKey] as? MessageClient.MessageUpdateNotification {
					switch updateNotification {
					case .updated(let tribeId, let message):
						if tribeId == self.tribe.id && message.tag == .tea && !self.tea.contains(message) {
							DispatchQueue.main.async {
								self.tea.updateOrAppend(message)
							}
							self.updateCurrentDraftOrTeaId()
						}
					case .deleted(let tribeId, let messageId):
						if tribeId == self.tribe.id {
							DispatchQueue.main.async {
								self.tea.remove(id: messageId)
							}
							self.updateCurrentDraftOrTeaId()
						}
					case .draftsUpdated(let tribeId, let drafts):
						if tribeId == self.tribe.id {
							let teaDrafts = IdentifiedArrayOf(uniqueElements: drafts.filter { $0.tag == .tea }.sorted(by: { $0.timeStamp < $1.timeStamp }))
							DispatchQueue.main.async {
								withAnimation(.easeInOut) {
									self.drafts = teaDrafts
								}
							}
							self.updateCurrentDraftOrTeaId()
						}
					}
				}
			}
		}
	}
}
