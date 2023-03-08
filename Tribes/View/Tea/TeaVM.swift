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
		
		@Published var tea: IdentifiedArrayOf<Message>
		
		//Clients
		let messageClient: MessageClient = MessageClient.shared
		
		init(tribe: Tribe) {
			self.tea = messageClient.tribesMessages[id: tribe.id]?.tea ?? []
		}
	}
}
