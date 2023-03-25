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
		enum Sheet: Equatable {
			case removeMember
			
			var title: String {
				switch self {
				case .removeMember: return "Remove"
				}
			}
			
			var body: String {
				switch self {
				case .removeMember: return "Are you sure you would like to remove"
				}
			}
			
			var confirmationTitle: String {
				switch self {
				case .removeMember: return "Remove"
				}
			}
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
		
		var isRemoveConfirmationButtonEnabled: Bool {
			return removeConfirmation == sheet?.confirmationTitle
		}
		
		@Published var tribe: Tribe
		@Published var drafts: IdentifiedArrayOf<MessageDraft>
		@Published var messages: IdentifiedArrayOf<Message>
		@Published var draftChangedId: UUID?
		@Published var messageChangedId: UUID?
		@Published var currentShowingTea: Message?
		@Published var isShowingMember: Bool = false
		@Published var isProcessingRemoveRequest: Bool = false
		@Published var memberToShow: TribeMember?
		@Published var removeConfirmation: String = ""
		@Published var text: String = ""
		@Published var sheet: Sheet?
		@Published var sheetBanner: BannerData?
		
		//Clients
		let apiClient: APIClient = APIClient.shared
		let feedbackClient: FeedbackClient = FeedbackClient.shared
		let messageClient: MessageClient = MessageClient.shared
		
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
		
		func retryDraft(draft: MessageDraft) {
			messageClient.postMessage(draft: draft)
			self.feedbackClient.medium()
		}
		
		func deleteDraft(draft: MessageDraft) {
			messageClient.deleteDraft(draft)
			self.feedbackClient.medium()
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
		
		func markAsRead() {
			if let lastMessage = self.messages.last {
				self.messageClient.markChatAsRead(tribeId: self.tribe.id, lastRead: lastMessage.timeStamp)
			}
		}
		
		func showTea(_ messageId: Message.ID) {
			if let message = self.messageClient.tribesMessages[id: tribe.id]?.tea[id: messageId] {
				withAnimation(self.teaAnimation) {
					self.currentShowingTea = message
				}
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
		
		func setSheet(_ sheet: Sheet?) {
			self.removeConfirmation = ""
			self.sheet = sheet
		}
		
		func requestToRemoveTribeMember() {
			setSheet(.removeMember)
		}
		
		func removeTribeMember() {
			guard
				let memberToRemove = self.memberToShow,
				self.isRemoveConfirmationButtonEnabled
			else { return }
			self.isProcessingRemoveRequest = true
			self.apiClient.removeMember(tribeID: tribe.id, memberId: memberToRemove.id)
				.receive(on: DispatchQueue.main)
				.sink(
					receiveCompletion: { [weak self] completion in
						switch completion {
						case .finished:
							self?.isProcessingRemoveRequest = false
						case .failure(let error):
							self?.isProcessingRemoveRequest = false
							self?.sheetBanner = BannerData(error: error)
						}
					},
					receiveValue: { [weak self] _ in
						guard let self = self else { return }
						self.dismissTribeMemberCard()
						self.setSheet(nil)
					}
				)
				.store(in: &cancellables)
		}
		
		@objc func updateMessage(notification: NSNotification) {
			if let dict = notification.userInfo as? NSDictionary {
				if let updateNotification = dict[AppConstants.messageNotificationDictionaryKey] as? MessageClient.MessageUpdateNotification {
					switch updateNotification {
					case .updated(let tribeId, let message):
						if tribeId == self.tribe.id && message.tag == .chat {
							var updatedMessages = self.messages
							updatedMessages.updateOrAppend(message)
							updatedMessages.sort(by: { $0.timeStamp < $1.timeStamp })
							DispatchQueue.main.async {
								self.messages = updatedMessages
								self.messageChangedId = UUID()
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
