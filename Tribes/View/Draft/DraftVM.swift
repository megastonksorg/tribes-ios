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
		@Published var recipients: IdentifiedArrayOf<Tribe>
		
		init(content: Message.Content? = nil, directRecipient: Tribe?) {
			self.content = content
			self.directRecipient = directRecipient
			self.recipients = TribesRepository.shared.getTribes().filter { $0.members.count > 1 }
		}
		
		func setContent(content: Message.Content) {
			self.content = content
		}
		
		func resetContent() {
			self.content = nil
		}
	}
}
