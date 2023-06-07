//
//  DraftVM.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-12-30.
//

import Foundation
import IdentifiedCollections
import UIKit

extension DraftView {
	@MainActor class ViewModel: ObservableObject {
		enum FocusField: Hashable {
			case caption
		}
		
		enum Mode {
			case media
			case note
		}
		
		@Published var caption: String = ""
		@Published var content: Message.Body.Content?
		@Published var pendingContent: PendingContent?
		@Published var directRecipient: Tribe?
		@Published var allowedRecipients: Set<Tribe.ID> = []
		@Published var selectedRecipients: IdentifiedArrayOf<Tribe> = []
		@Published var recipients: IdentifiedArrayOf<Tribe> = []
		
		@Published var mode: Mode = .media
		
		@Published var isPlaying: Bool = true
		@Published var isUploading: Bool = false
		@Published var banner: BannerData?
		
		@Published var noteComposeVM: NoteComposeView.ViewModel = NoteComposeView.ViewModel()
		
		var canSendTea: Bool {
			selectedRecipients.count > 0
		}
		
		var isShowingCaption: Bool {
			!caption.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
		}
		
		var isShowingRecipients: Bool {
			switch mode {
			case .media: return true
			case .note: return noteComposeVM.isDoneTyping
			}
		}
		
		//Clients
		let feedbackClient: FeedbackClient = FeedbackClient.shared
		let messageClient: MessageClient = MessageClient.shared
		let pendingContentClient: PendingContentClient = PendingContentClient.shared
		let keyboardClient: KeyboardClient = KeyboardClient.shared
		
		init(content: Message.Body.Content? = nil) {
			self.content = content
			resetRecipients()
		}
		
		func didDisappear() {
			self.resetContent(shouldResetPendingContent: false)
			self.resetRecipients()
		}
		
		func setContent(content: Message.Body.Content) {
			self.content = content
			self.pendingContent = self.pendingContentClient.set(content: content)
		}
		
		func setMode(_ mode: Mode) {
			self.mode = mode
		}
		
		func resetContent(shouldResetPendingContent: Bool) {
			self.keyboardClient.resignKeyboard()
			self.content = nil
			self.mode = .media
			self.noteComposeVM = NoteComposeView.ViewModel()
			self.caption = ""
			self.isPlaying = true
			if shouldResetPendingContent {
				if let pendingContent = self.pendingContent {
					self.pendingContentClient.remove(pendingContent: pendingContent)
				}
			}
			self.pendingContent = nil
		}
		
		func setAllowedRecipients(_ recipients: Set<Tribe.ID>) {
			self.allowedRecipients = recipients
		}
		
		func resetRecipients() {
			if let directRecipient = self.directRecipient {
				if allowedRecipients.contains(directRecipient.id) {
					self.selectedRecipients = IdentifiedArrayOf(uniqueElements: [directRecipient])
				}
			} else {
				self.recipients = TribesRepository.shared.getTribes().filter { $0.members.count > 1 }
				self.selectedRecipients = []
			}
		}
		
		func tribeTapped(tribe: Tribe) {
			if self.allowedRecipients.contains(tribe.id) {
				if let tribe = self.selectedRecipients[id: tribe.id] {
					self.selectedRecipients.remove(tribe)
				} else {
					self.selectedRecipients.append(tribe)
				}
			} else {
				self.banner = BannerData(detail: "has shared enough (40) for the day", type: .tribe(tribe.name))
			}
		}
		
		func sendTea() {
			guard
				let content = self.content,
				var pendingContent = self.pendingContent
			else { return }
			//Stop playing content when the upload starts
			self.isPlaying = false
			self.isUploading = true
			let caption: String? = {
				if self.isShowingCaption {
					return self.caption
				} else if self.noteComposeVM.isTextValid {
					//We update the Note information here for upload
					self.pendingContentClient.remove(pendingContent: pendingContent)
					if let newPendingContent = self.pendingContentClient.set(
						content: .note(URL(string: "https:/tribesapp.ca?\(AppConstants.noteBackgroundKey)=\(noteComposeVM.backgroundStyle.rawValue)")!)
					) {
						pendingContent = newPendingContent
					}
					return self.noteComposeVM.text
				} else {
					return nil
				}
			}()
			if let directRecipient = self.directRecipient {
				let teaDraft = MessageDraft(
					id: UUID(),
					content: content,
					contextId: nil,
					caption: caption,
					tag: .tea,
					tribeId: directRecipient.id,
					timeStamp: Date.now,
					pendingContent: pendingContent
				)
				messageClient.postDraft(teaDraft)
			} else {
				self.selectedRecipients.forEach { tribe in
					let teaDraft = 	MessageDraft(
						id: UUID(),
						content: content,
						contextId: nil,
						caption: caption,
						tag: .tea,
						tribeId: tribe.id,
						timeStamp: Date.now,
						pendingContent: pendingContent
					)
					messageClient.postDraft(teaDraft)
				}
			}
			NotificationCenter.default.post(Notification(name: .toggleCompose))
			self.feedbackClient.medium()
			self.isUploading = false
		}
	}
}
