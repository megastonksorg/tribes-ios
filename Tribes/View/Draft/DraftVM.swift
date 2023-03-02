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
		@Published var content: Message.Content?
		@Published var directRecipient: Tribe?
		@Published var selectedRecipients: IdentifiedArrayOf<Tribe> = []
		@Published var recipients: IdentifiedArrayOf<Tribe>
		
		var canSendTea: Bool {
			selectedRecipients.count > 0
		}
		
		init(content: Message.Content? = nil, directRecipient: Tribe?) {
			self.content = content
			self.directRecipient = directRecipient
			self.recipients = IdentifiedArrayOf(uniqueElements: [Tribe.noop2, Tribe.noop3, Tribe.noop4, Tribe.noop5, Tribe.noop6]) //TribesRepository.shared.getTribes().filter { $0.members.count > 1 }
			if let directRecipient = directRecipient {
				self.selectedRecipients = IdentifiedArrayOf(uniqueElements: [directRecipient])
			}
		}
		
		func setContent(content: Message.Content) {
			self.content = content
		}
		
		func resetContent() {
			self.content = nil
		}
		
		func tribeTapped(tribe: Tribe) {
			if let tribe = self.selectedRecipients[id: tribe.id] {
				self.selectedRecipients.remove(id: tribe.id)
			} else {
				self.selectedRecipients.append(tribe)
			}
		}
	}
}
