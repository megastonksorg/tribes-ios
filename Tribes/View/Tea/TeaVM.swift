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
		
		var teaIsEmpty: Bool {
			tea.isEmpty && teaDrafts.isEmpty
		}
		
		@Published var teaDrafts: IdentifiedArrayOf<MessageDraft>
		@Published var tea: IdentifiedArrayOf<Message>
		@Published var text: String = ""
		
		//Clients
		let messageClient: MessageClient = MessageClient.shared
		
		init(tribe: Tribe) {
			self.currentTribeMember = tribe.members.currentMember ?? TribeMember.dummyTribeMember
			self.tribe = tribe
			self.teaDrafts = messageClient.tribesMessages[id: tribe.id]?.teaDrafts ?? []
			self.tea = messageClient.tribesMessages[id: tribe.id]?.tea ?? []
			
			self.messageClient.$tribesMessages
				.sink(
					receiveValue: { tribesMessages in
						self.tea = tribesMessages[id: tribe.id]?.tea ?? []
						self.teaDrafts = tribesMessages[id: tribe.id]?.teaDrafts ?? []
					}
				)
				.store(in: &cancellables)
		}
	}
}
