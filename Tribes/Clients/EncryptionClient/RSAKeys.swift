//
//  RSAKeys.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-16.
//

import Foundation

fileprivate let rsaKeySizeInBits: NSNumber = 2048
fileprivate let rsaAlgorithm: SecKeyAlgorithm = .rsaEncryptionPKCS1

struct RSAKeys {
	struct PublicKey {
		let key: SecKey
		
		init(key: SecKey) {
			self.key = key
		}
		
		init?(data: Data) {
			if let key = PublicKey.loadFromData(data) {
				self.key = key
				return
			}
			return nil
		}
		
		///
		/// Takes the data and uses the public key to encrypt it.
		/// Returns the encrypted data.
		///
		func encrypt(data: Data) -> Data? {
			var error: Unmanaged<CFError>?
			if let encryptedData: CFData = SecKeyCreateEncryptedData(self.key, rsaAlgorithm, data as CFData, &error) {
				if error != nil {
					return nil
				} else {
					return encryptedData as Data
				}
			} else {
				return nil
			}
		}
		
		static func loadFromData(_ data: Data) -> SecKey? {
			let keyDict: [NSObject : NSObject] = [
				kSecAttrKeyType: kSecAttrKeyTypeRSA,
				kSecAttrKeyClass: kSecAttrKeyClassPublic,
				kSecAttrKeySizeInBits: rsaKeySizeInBits
			]
			return SecKeyCreateWithData(data as CFData, keyDict as CFDictionary, nil)
		}
	}
	
	struct PrivateKey {
		let key: SecKey
		
		init(key: SecKey) {
			self.key = key
		}
		
		init?(data: Data) {
			if let key = PrivateKey.loadFromData(data) {
				self.key = key
				return
			}
			return nil
		}
		
		///
		/// Takes the data and uses the private key to decrypt it.
		/// Returns the decrypted data.
		///
		func decrypt(data: Data) -> Data? {
			var error: Unmanaged<CFError>?
			if let decryptedData: CFData = SecKeyCreateDecryptedData(key, rsaAlgorithm, data as CFData, &error) {
				if error != nil {
					return nil
				} else {
					return decryptedData as Data
				}
			} else {
				return nil
			}
		}
		
		static func loadFromData(_ data: Data) -> SecKey? {
			let keyDict: [NSObject : NSObject] = [
				kSecAttrKeyType: kSecAttrKeyTypeRSA,
				kSecAttrKeyClass: kSecAttrKeyClassPrivate,
				kSecAttrKeySizeInBits: rsaKeySizeInBits
			]
			return SecKeyCreateWithData(data as CFData, keyDict as CFDictionary, nil)
		}
	}
	
	let privateKey: PrivateKey
	let publicKey: PublicKey
	
	//Will create a brand new RSA private and public key pair for asymmetric cryptography
	static func generateRandomRSAKeyPair() -> RSAKeys? {
		let privateAttributes: [NSObject : Any] = [
			kSecAttrIsPermanent: false
		]
		let publicAttributes: [NSObject : Any] = [:]
		let pairAttributes: [NSObject : Any] = [
			kSecAttrKeyType: kSecAttrKeyTypeRSA,
			kSecAttrKeySizeInBits: rsaKeySizeInBits,
			kSecPublicKeyAttrs: publicAttributes,
			kSecPrivateKeyAttrs: privateAttributes
		]
		
		var error: Unmanaged<CFError>?
		if let privateKey: SecKey = SecKeyCreateRandomKey(pairAttributes as CFDictionary, &error),
		   let publicKey: SecKey = SecKeyCopyPublicKey(privateKey) {
			if error != nil {
				return nil
			} else {
				return RSAKeys(privateKey: PrivateKey(key: privateKey), publicKey: PublicKey(key: publicKey))
			}
		} else {
			return nil
		}
	}
}

extension SecKey {
	func exportToData() -> Data? {
		var error: Unmanaged<CFError>?
		if let cfData = SecKeyCopyExternalRepresentation(self, &error) {
			if error != nil {
				return nil
			} else {
				return cfData as Data
			}
		} else {
			return nil
		}
	}
}
