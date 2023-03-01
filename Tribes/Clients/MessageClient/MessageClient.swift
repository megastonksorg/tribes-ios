//
//  MessageClient.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-28.
//

import Foundation
import IdentifiedCollections

/**
 Sending a Message
 (1): Generate Encrypted Data
 (2): Send data across the wire if it is an image or video
 (3): Use received URL to compose PostMessageRequest
 (4): Encrypt and append caption if the user adds one
 */

@MainActor class MessageClient: ObservableObject {
	struct TribeAndMessages: Identifiable {
		let tribe: Tribe
		let tea: IdentifiedArrayOf<Message>
		let chat: IdentifiedArrayOf<Message>
		let lastReadTea: Date?
		let lastReadChat: Date?
		
		var id: Tribe.ID { tribe.id }
	}
	
	@Published var tribesAndMessages: IdentifiedArrayOf<TribeAndMessages> = []
	
	init() {
		
	}
}