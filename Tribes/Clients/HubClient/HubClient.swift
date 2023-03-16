//
//  HubClient.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-03-16.
//

import Foundation
import SignalRClient

class HubClient {
	private var connection: HubConnection
	
	init() {
		connection = HubConnectionBuilder(url: URL(string: "https://\(APPUrlRequest.domain)/appHub")!)
			.withLogging(minLogLevel: .error)
			.withAutoReconnect()
			.build()
		
		//Register for Events
		connection.on(method: "receiveMessage", callback: { (tribeId: String, message: MessageResponse) in
			self.handleMessage(tribeId, message: message)
		})
		
		connection.start()
	}
	
	private func handleMessage(_ tribeId: String, message: MessageResponse) {
		Task {
			await MessageClient.shared.messageReceived(tribeId: tribeId, messageResponse: message)
		}
	}
}
