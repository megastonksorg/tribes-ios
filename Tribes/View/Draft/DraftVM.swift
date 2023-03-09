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
		
		@Published var caption: String = ""
		@Published var content: Message.Body.Content?
		@Published var directRecipient: Tribe?
		@Published var selectedRecipients: IdentifiedArrayOf<Tribe> = []
		@Published var recipients: IdentifiedArrayOf<Tribe> = []
		
		@Published var isLoading: Bool = false
		
		var canSendTea: Bool {
			selectedRecipients.count > 0
		}
		
		var isShowingCaption: Bool {
			!caption.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
		}
		
		//Clients
		let messageClient: MessageClient = MessageClient.shared
		let feedbackClient: FeedbackClient = FeedbackClient.shared
		
		init(content: Message.Body.Content? = nil) {
			self.content = content
			resetRecipients()
		}
		
		func didDisappear() {
			self.resetContent()
			self.resetRecipients()
		}
		
		func setContent(content: Message.Body.Content) {
			self.content = content
		}
		
		func resetContent() {
			self.content = nil
			self.caption = ""
		}
		
		func resetRecipients() {
			if let directRecipient = self.directRecipient {
				self.selectedRecipients = IdentifiedArrayOf(uniqueElements: [directRecipient])
			} else {
				self.recipients = TribesRepository.shared.getTribes().filter { $0.members.count > 1 }
				self.selectedRecipients = []
			}
		}
		
		func tribeTapped(tribe: Tribe) {
			if let tribe = self.selectedRecipients[id: tribe.id] {
				self.selectedRecipients.remove(tribe)
			} else {
				self.selectedRecipients.append(tribe)
			}
		}
		
		func sendTea() {
			guard let content = self.content else { return }
			self.isLoading = true
			let caption: String? = {
				if self.isShowingCaption {
					return self.caption
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
					tribeId: directRecipient.id
				)
				messageClient.postMessage(draft: teaDraft)
				NotificationCenter.default.post(Notification(name: .toggleCompose))
				self.feedbackClient.medium()
			}
			self.isLoading = false
		}
	}
}
