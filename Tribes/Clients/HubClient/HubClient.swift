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
	static let shared: HubClient = HubClient()
	
	private var connection: HubConnection?
	
	init() {
		initializeConnection()
		
		NotificationCenter
			.default.addObserver(
				self,
				selector: #selector(subscribeToTribeUpdates),
				name: .tribesUpdated,
				object: nil
			)
	}
	
	func initializeConnection() {
		self.connection?.stop()
		self.connection = nil
		
		connection = HubConnectionBuilder(url: URL(string: "https://\(APPUrlRequest.domain)/appHub")!)
			.withLogging(minLogLevel: .error)
			.withHubConnectionDelegate(delegate: self)
			.withAutoReconnect()
			.build()
		
		//Register for Events
		connection?.on(method: "ReceiveMessage", callback: { (tribeId: String, message: MessageResponse) in
			self.handleMessage(tribeId, message: message)
		})
		
		connection?.on(method: "TribeUpdated") {
			self.handleTribeUpdated()
		}
		
		connection?.start()
	}
	
	func stopConnection() {
		self.connection?.stop()
	}
	
	private func handleMessage(_ tribeId: String, message: MessageResponse) {
		Task {
			await MessageClient.shared.messageReceived(tribeId: tribeId, messageResponse: message)
		}
	}
	
	private func handleTribeUpdated() {
		TribesRepository.shared.refreshTribes()
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
	
	@objc func subscribeToTribeUpdates() {
		if let user = KeychainClient.shared.get(key: .user) {
			let signalRMethodName: String = "SubscribeToTribes"
			let signedMessageResult = WalletClient.shared.signMessage(message: signalRMethodName)
			switch signedMessageResult {
			case .success(let signedMessage):
				connection?.invoke(method: signalRMethodName, user.walletAddress, signedMessage.signature) { _ in }
			case .failure: return
			}
		}
	}
}
