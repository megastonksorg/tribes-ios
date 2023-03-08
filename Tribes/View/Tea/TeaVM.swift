//
//  TeaVM.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-12-30.
//

import Foundation
import IdentifiedCollections
import SwiftUI

extension TeaView {
	@MainActor class ViewModel: ObservableObject {
		let currentTribeMember: TribeMember
		let tribe: Tribe
		
		@Published var tea: IdentifiedArrayOf<Message>
		
		//Clients
		let messageClient: MessageClient = MessageClient.shared
		
		init(tribe: Tribe) {
			self.currentTribeMember = tribe.members.currentMember ?? TribeMember.dummyTribeMember
			self.tribe = tribe
			self.tea = messageClient.tribesMessages[id: tribe.id]?.tea ?? []
		}
	}
}
