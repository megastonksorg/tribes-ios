//
//  WalletClient.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-06-01.
//

import WalletCore
import SwiftKeychainWrapper

struct SignedMessage {
	let signature: String
	let publicKey: String
}

protocol WalletClientProtocol {
	typealias WalletClientError = AppError.WalletError
	
	func generateNewWallet() -> Result<HDWallet, WalletClientError>
	func getAddress(_ hdWallet: HDWallet) -> String
	func getPublicKey() -> String?
	func getMnemonic() -> Result<String, WalletClientError>
	func hashMessage(message: String) -> String?
	func importWallet(mnemonic: String) -> Result<HDWallet, WalletClientError>
	func saveMnemonic(mnemonic: String)
	func signMessage(message: String) -> Result<SignedMessage, WalletClientError>
	func verifyMnemonic(mnemonic: String) -> Result<String, WalletClientError>
}

class WalletClient: WalletClientProtocol {
	static let shared = WalletClient()
	
	private let passPhrase: String = ""
	private let coinType: WalletCore.CoinType = .ethereum
	private let keychainClient: KeychainClient = KeychainClient.shared
	
	func generateNewWallet() -> Result<HDWallet, WalletClientError> {
		guard let wallet = HDWallet(strength: 128, passphrase: passPhrase)
		else { return .failure(.couldNotGenerateWallet) }
		return .success(wallet)
	}
	
	func getAddress(_ hdWallet: HDWallet) -> String {
		return hdWallet.getAddressForCoin(coin: coinType)
	}
	
	func getPublicKey() -> String? {
		guard
			let mnemonic = self.keychainClient.get(key: .mnemonic),
			let hdWallet = HDWallet(mnemonic: mnemonic, passphrase: "")
		else { return nil }
		return hdWallet.getKeyForCoin(coin: coinType).getPublicKeySecp256k1(compressed: false).description
	}
	
	func getMnemonic() -> Result<String, WalletClientError> {
		guard let mnemonic: String = keychainClient.get(key: .mnemonic)
		else { return .failure(.errorRetrievingMnemonic) }
		return .success(mnemonic)
	}
	
	func hashMessage(message: String) -> String? {
		guard let messageData = message.data(using: .utf8) else { return nil }
		let hashedData: Data = WalletCore.Hash.keccak256(data: messageData)
		return hashedData.hexString
	}
	
	func importWallet(mnemonic: String) -> Result<HDWallet, WalletClientError> {
		guard let wallet = HDWallet(mnemonic: mnemonic, passphrase: passPhrase, check: true)
		else { return .failure(.couldNotImportWallet) }
		return .success(wallet)
	}
	
	func saveMnemonic(mnemonic: String) {
		keychainClient.set(key: .mnemonic, value: mnemonic)
	}
	
	func signMessage(message: String) -> Result<SignedMessage, WalletClientError> {
		guard
			let mnemonic: String = keychainClient.get(key: .mnemonic),
			let wallet: HDWallet = HDWallet(mnemonic: mnemonic, passphrase: passPhrase, check: true)
		else { return .failure(.couldNotImportWalletForSigning) }
		
		let privateKey = wallet.getKeyForCoin(coin: coinType)

		guard let messageData = message.data(using: .utf8)
		else { return .failure(.errorSigningMessage) }
		
		let hash: Data = WalletCore.Hash.keccak256(data: messageData)
		
		guard let signature = privateKey.sign(digest: hash, curve: .secp256k1)
		else { return .failure(.errorSigningMessage) }
		
		let publicKey = privateKey.getPublicKeySecp256k1(compressed: false).description
		
		return .success(SignedMessage(signature: signature.hexString, publicKey: publicKey))
	}
	
	func verifyMnemonic(mnemonic: String) -> Result<String, WalletClientError> {
		switch self.getMnemonic() {
			case .success(let savedMnemonic):
				if mnemonic == savedMnemonic {
					guard case .success(let wallet) = self.importWallet(mnemonic: mnemonic) else { return .failure(.couldNotVerifyMnemonic) }
					
					return .success(wallet.getAddressForCoin(coin: coinType))
				}
				else {
					return .failure(.couldNotVerifyMnemonic)
				}
			case .failure(let error):
				return .failure(error)
		}
	}
}
