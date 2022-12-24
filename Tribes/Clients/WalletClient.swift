//
//  WalletClient.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-06-01.
//

import WalletCore
import SwiftKeychainWrapper

class WalletClient {
	
	typealias WalletClientError = AppError.WalletError
	
	struct SignedMessage {
		let signature: String
		let address: String
	}
	
	private let passPhrase: String = ""
	private let coinType: WalletCore.CoinType = .ethereum
	
	static let shared = WalletClient()
	
	func generateNewWallet() -> Result<HDWallet, WalletClientError> {
		guard let wallet = HDWallet(strength: 128, passphrase: passPhrase)
		else { return .failure(.couldNotGenerateWallet) }
		return .success(wallet)
	}
	
	func importWallet(mnemonic: String) -> Result<HDWallet, WalletClientError> {
		guard let wallet = HDWallet(mnemonic: mnemonic, passphrase: passPhrase, check: true)
		else { return .failure(.couldNotImportWallet) }
		return .success(wallet)
	}
	
	func saveMnemonic(mnemonic: String) {
		KeychainWrapper.standard.set(mnemonic, forKey: KeychainWrapper.Key.mnemonic.rawValue)
	}
	
	func getMnemonic() -> Result<String, WalletClientError> {
		guard let mnemonic: String = KeychainWrapper.standard.string(forKey: .mnemonic)
		else { return .failure(.errorRetrievingMnemonic) }
		return .success(mnemonic)
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
	
	func signMessage(message: String) -> Result<SignedMessage, WalletClientError> {
		guard
			let mnemonic: String = KeychainWrapper.standard.string(forKey: .mnemonic),
			let wallet: HDWallet = HDWallet(mnemonic: mnemonic, passphrase: passPhrase, check: true)
		else { return .failure(.couldNotImportWalletForSigning) }
		
		let privateKey = wallet.getKeyForCoin(coin: coinType)

		guard let messageData = message.data(using: .utf8)
		else { return .failure(.errorSigningMessage) }
		
		let hash: Data = WalletCore.Hash.keccak256(data: messageData)
		
		guard let signature = privateKey.sign(digest: hash, curve: .secp256k1)
		else { return .failure(.errorSigningMessage) }
		
		let address = privateKey.getPublicKeySecp256k1(compressed: false).description
		
		return .success(SignedMessage(signature: signature.hexString, address: address))
	}
	
	func getAddress(_ hdWallet: HDWallet) -> String {
		return hdWallet.getAddressForCoin(coin: coinType)
	}
}
