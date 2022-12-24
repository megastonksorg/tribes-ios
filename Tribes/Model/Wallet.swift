//
//  Wallet.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-06-01.
//

import WalletCore

struct Wallet {
	var privateKey: WalletCore.PrivateKey
	var publicKey: WalletCore.PublicKey
	var address: WalletCore.Address
	var network: WalletCore.CoinType
}
