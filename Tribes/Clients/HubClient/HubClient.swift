//
//  HubClient.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-03-16.
//

import Foundation
import IdentifiedCollections
import SignalRClient

class HubClient: HubConnectionDelegate {
	private var connection: HubConnection?
	
	init() {
		connection = HubConnectionBuilder(url: URL(string: "https://\(APPUrlRequest.domain)/appHub")!)
			.withLogging(minLogLevel: .error)
			.withHubConnectionDelegate(delegate: self)
			.withAutoReconnect()
			.build()
		
		//Register for Events
		connection?.on(method: "ReceiveMessage", callback: { (tribeId: String, message: MessageResponse) in
			self.handleMessage(tribeId, message: message)
		})
		
		connection?.start()
	}
	
	func subscribeToTribeUpdates() {
		let tribes = TribesRepository.shared.getTribes()
		tribes.forEach { tribe in
			connection?.invoke(method: "JoinGroup", tribe.id) { _ in }
		}
	}
	
	private func handleMessage(_ tribeId: String, message: MessageResponse) {
		Task {
			await MessageClient.shared.messageReceived(tribeId: tribeId, messageResponse: message)
		}
	}
	
	internal func connectionDidOpen(hubConnection: SignalRClient.HubConnection) {
		//Join Tribes Group
		subscribeToTribeUpdates()
	}
	
	internal func connectionDidFailToOpen(error: Error) {
		connection?.start()
	}
	
	internal func connectionDidClose(error: Error?) {
		return
	}
}

