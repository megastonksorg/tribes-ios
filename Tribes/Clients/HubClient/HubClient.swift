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
		initializeConnection()
		
		/**
		 We need to reinitialize the connection when the token is refreshed because
		 there is a possibility the user was not able to join the room for all his tribes in the server
		 */
		NotificationCenter
			.default.addObserver(
				self,
				selector: #selector(initializeConnection),
				name: .tokenRefreshed,
				object: nil
			)
	}
	
	private func handleMessage(_ tribeId: String, message: MessageResponse) {
		Task {
			await MessageClient.shared.messageReceived(tribeId: tribeId, messageResponse: message)
		}
	}
	
	internal func connectionDidOpen(hubConnection: SignalRClient.HubConnection) {
		//Join Tribes Group
		self.subscribeToTribeUpdates()
	}
	
	internal func connectionDidFailToOpen(error: Error) {
		self.connection?.start()
	}
	
	internal func connectionDidClose(error: Error?) {
		return
	}
	
	@objc func initializeConnection() {
		self.connection?.stop()
		self.connection = nil
		if let token = KeychainClient.shared.get(key: .token) {
			let accessToken = token.jwt
			connection = HubConnectionBuilder(url: URL(string: "https://\(APPUrlRequest.domain)/appHub")!)
				.withLogging(minLogLevel: .error)
				.withHubConnectionDelegate(delegate: self)
				.withHttpConnectionOptions(
					configureHttpOptions: { httpOptions in
						httpOptions.accessTokenProvider = { accessToken }
				})
				.withAutoReconnect()
				.build()
			
			//Register for Events
			connection?.on(method: "ReceiveMessage", callback: { (tribeId: String, message: MessageResponse) in
				self.handleMessage(tribeId, message: message)
			})
			
			connection?.start()
			
			NotificationCenter
				.default.addObserver(
					self,
					selector: #selector(subscribeToTribeUpdates),
					name: .tribesUpdated,
					object: nil
				)
		}
	}
	
	@objc func subscribeToTribeUpdates() {
		let tribes = TribesRepository.shared.getTribes()
		tribes.forEach { tribe in
			connection?.invoke(method: "JoinGroup", tribe.id) { _ in }
		}
	}
}
