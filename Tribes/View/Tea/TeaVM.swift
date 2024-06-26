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
		
		var isHintTextVisible: Bool {
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
		@Published var readTea: MessageClient.ReadMessage
		@Published var text: String = ""
		@Published var isShowingTeaView: Bool = false
		@Published var isShowingTribeProfile: Bool = false
		
		//Clients
		let apiClient: APIClient = APIClient.shared
		let feedbackClient: FeedbackClient = FeedbackClient.shared
		let messageClient: MessageClient = MessageClient.shared
		let pendingContentClient: PendingContentClient = PendingContentClient.shared
		
		init(tribe: Tribe) {
			let drafts = messageClient.tribesMessages[id: tribe.id]?.teaDrafts.sorted(by: { $0.timeStamp > $1.timeStamp }) ?? []
			let tea = messageClient.tribesMessages[id: tribe.id]?.tea ?? []
			self.currentTribeMember = tribe.members.currentMember ?? TribeMember.dummyTribeMember
			self.tribe = tribe
			self.drafts = IdentifiedArrayOf(uniqueElements: drafts)
			self.tea = tea
			self.readTea = messageClient.readMessage
			
			self.setCurrentDraftOrTeaId()
			
			self.messageClient.$readMessage
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
		
		func didAppear() {
			self.loadTeaViewers()
		}
		
		func setCurrentDraftOrTeaId() {
			DispatchQueue.main.async {
				if !self.draftAndTeaIds.isEmpty {
					if let id: String = self.draftAndTeaIds[safe: self.currentPill] {
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
							if !(self.currentTea?.isEncrypted ?? false) {
								self.markTeaAsViewed()
							}
							return
						}
					}
				}
			}
			if !self.draftAndTeaIds.isEmpty {
				if let id: String = self.draftAndTeaIds[safe: self.currentPill] {
					//Mark the tea as read
					if let tea = self.tea[id: id] {
						if !tea.isRead {
							self.messageClient.markMessageAsRead(tea.id)
						}
					}
				}
			}
		}
		
		func showTeaView(id: String) {
			self.isShowingTeaView = true
			if let index = self.draftAndTeaIds.firstIndex(of: id) {
				self.currentPill = index
				setCurrentDraftOrTeaId()
			}
		}
		
		func showTribeProfile() {
			self.isShowingTribeProfile = true
		}
		
		func dismissTeaView() {
			DispatchQueue.main.async {
				self.isShowingTeaView = false
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
					self.messageClient.postDraft(failedDraft, isRetry: true)
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
			let content: Message.Body.Content = .text(text)
			guard
				!text.isEmpty,
				let currentTeaId = self.currentTeaId,
				let pendingContent = self.pendingContentClient.set(content: content)
			else { return }
			
			let draft: MessageDraft = MessageDraft(
				id: UUID(),
				content: content,
				contextId: currentTeaId,
				caption: nil,
				tag: .chat,
				tribeId: tribe.id,
				timeStamp: Date.now,
				pendingContent: pendingContent
			)
			
			self.text = ""
			messageClient.postDraft(draft, isRetry: false)
			self.feedbackClient.medium()
		}
		
		func isDraftOrTeaRead(pillIndex: Int) -> Bool {
			if !self.draftAndTeaIds.isEmpty {
				if let id: String = self.draftAndTeaIds[safe: pillIndex] {
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
		
		func loadTeaViewers() {
			self.tea.forEach { tea in
				self.apiClient
					.getMessageViewers(messageId: tea.id)
					.receive(on: DispatchQueue.main)
					.sink(
						receiveCompletion: { _ in },
						receiveValue: { walletAddresses in
							var uniqueWalletAddresses = Set(walletAddresses)
							uniqueWalletAddresses.remove(self.currentTribeMember.id)
							self.teaViewers.updateOrAppend(
								TeaViewer(
									id: tea.id,
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
						if tribeId == self.tribe.id && message.tag == .tea {
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
									if self.drafts.isEmpty {
										self.drafts = teaDrafts
									}
									else {
										self.drafts = teaDrafts
										self.updateCurrentDraftOrTeaId()
									}
								}
							}
						}
					}
				}
			}
		}
	}
}
