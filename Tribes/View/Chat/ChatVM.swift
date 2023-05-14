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
		
		let scrollAnimation: Animation = Animation.easeIn
		let teaAnimation: Animation = Animation.easeInOut
		let currentTribeMember: TribeMember
		private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
		
		var canChat: Bool {
			tribe.members.others.count > 0
		}
		
		var isHintTextVisible: Bool {
			text.isEmpty
		}
		
		var canSendText: Bool {
			!text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
		}
		
		var lastDraftId: MessageDraft.ID? {
			failedDrafts.last?.id
		}
		
		var lastMessageId: Message.ID? {
			messages.last?.id
		}
		
		var failedDrafts: IdentifiedArrayOf<MessageDraft> {
			drafts.filter { $0.status == .failedToUpload || $0.isStuckUploading }
		}
		
		var isSendingMessage: Bool {
			drafts.contains(where: { $0.status == .uploading })
		}
		
		@Published var tribe: Tribe
		@Published var drafts: IdentifiedArrayOf<MessageDraft>
		@Published var messages: IdentifiedArrayOf<Message>
		@Published var draftChangedId: UUID?
		@Published var messageChangedId: UUID?
		@Published var currentShowingTea: Message?
		@Published var isShowingTribeProfile: Bool = false
		@Published var memberToShow: TribeMember?
		@Published var sheetConfirmation: String = ""
		@Published var text: String = ""
		
		//Clients
		let apiClient: APIClient = APIClient.shared
		let feedbackClient: FeedbackClient = FeedbackClient.shared
		let messageClient: MessageClient = MessageClient.shared
		let pendingContentClient: PendingContentClient = PendingContentClient.shared
		let tribesRepository: TribesRepository = TribesRepository.shared
		
		init(tribe: Tribe) {
			let tribeMessage: TribeMessage? = messageClient.tribesMessages[id: tribe.id]
			self.currentTribeMember = tribe.members.currentMember ?? TribeMember.dummyTribeMember
			self.tribe = tribe
			self.drafts = tribeMessage?.chatDrafts ?? []
			self.messages = tribeMessage?.chat ?? []
			
			NotificationCenter
				.default.addObserver(
					self,
					selector: #selector(updateTribe),
					name: .tribesUpdated,
					object: nil
				)
			
			NotificationCenter
				.default.addObserver(
					self,
					selector: #selector(updateMessage),
					name: .messageUpdated,
					object: nil
				)
		}
		
		func retryDraft(draft: MessageDraft) {
			messageClient.postDraft(draft)
			self.feedbackClient.medium()
		}
		
		func deleteDraft(draft: MessageDraft) {
			messageClient.deleteDraft(draft)
			self.feedbackClient.medium()
		}
		
		func sendMessage() {
			let content: Message.Body.Content = .text(self.text)
			guard canSendText,
				  let pendingContent = self.pendingContentClient.set(content: content)
			else { return }
			
			let draft = MessageDraft(
				id: UUID(),
				content: content,
				contextId: nil,
				caption: nil,
				tag: .chat,
				tribeId: tribe.id,
				timeStamp: Date.now,
				pendingContent: pendingContent
			)
			self.text = ""
			messageClient.postDraft(draft)
			self.feedbackClient.medium()
		}
		
		func scrollToLastMessage(proxy: ScrollViewProxy) {
			if let lastDraftId = lastDraftId {
				withAnimation(scrollAnimation) {
					proxy.scrollTo(lastDraftId, anchor: .bottom)
				}
				return
			}
			if let lastMessageId = lastMessageId {
				withAnimation(scrollAnimation) {
					proxy.scrollTo(lastMessageId, anchor: .bottom)
				}
			}
		}
		
		func shouldShowMessageAuthor(message: Message) -> Bool {
			if let indexOfCurrentMessage = self.messages.index(id: message.id) {
				let previousIndex = indexOfCurrentMessage - 1
				if self.messages.indices.contains(previousIndex) {
					if self.messages[previousIndex].senderId == message.senderId {
						return false
					}
				}
			}
			return true
		}
		
		func markAsRead(_ message: Message) {
			if !message.isRead {
				self.messageClient.markMessageAsRead(message.id)
			}
		}
		
		func showTea(_ messageId: Message.ID) {
			if let message = self.messageClient.tribesMessages[id: tribe.id]?.tea[id: messageId] {
				withAnimation(self.teaAnimation) {
					self.currentShowingTea = message
				}
				//Mark Tea as read if needed
				self.markAsRead(message)
				
			} else {
				withAnimation(self.teaAnimation) {
					self.currentShowingTea = nil
				}
			}
		}
		
		func dismissTea() {
			withAnimation(self.teaAnimation) {
				self.currentShowingTea = nil
			}
		}
		
		func showTribeProfile() {
			self.isShowingTribeProfile = true
		}
		
		@objc func updateMessage(notification: NSNotification) {
			if let dict = notification.userInfo as? NSDictionary {
				if let updateNotification = dict[AppConstants.messageNotificationDictionaryKey] as? MessageClient.MessageUpdateNotification {
					switch updateNotification {
					case .updated(let tribeId, let message):
						if tribeId == self.tribe.id && message.tag == .chat {
							DispatchQueue.main.async {
								let doesNotExist = !self.messages.ids.contains(message.id)
								var updatedMessages = self.messages
								updatedMessages.updateOrAppend(message)
								updatedMessages.sort(by: { $0.timeStamp < $1.timeStamp })
								self.messages = updatedMessages
								if doesNotExist {
									self.messageChangedId = UUID()
								}
							}
							if self.messages.count != self.messageClient.tribesMessages[id: self.tribe.id]?.chat.count {
								if let tribeChat = self.messageClient.tribesMessages[id: self.tribe.id]?.chat {
									DispatchQueue.main.async {
										self.messages = tribeChat
									}
								}
							}
						}
					case .deleted(let tribeId, let messageId):
						if tribeId == self.tribe.id {
							DispatchQueue.main.async {
								self.messages.remove(id: messageId)
								self.messageChangedId = UUID()
							}
						}
					case .draftsUpdated(let tribeId, let drafts):
						if tribeId == self.tribe.id {
							let chatDrafts = IdentifiedArrayOf(uniqueElements: drafts.filter { $0.tag == .chat }.sorted(by: { $0.timeStamp < $1.timeStamp }))
							DispatchQueue.main.async {
								withAnimation(.easeInOut) {
									self.drafts = chatDrafts
									self.draftChangedId = UUID()
								}
							}
						}
					}
				}
			}
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
