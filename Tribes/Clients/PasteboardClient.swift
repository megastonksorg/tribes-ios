//
//  PasteboardClient.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-08-03.
//

import UIKit

class PasteboardClient {
	static let shared: PasteboardClient = PasteboardClient()
	
	let pasteboard = UIPasteboard.general
	
	func copyText(_ text: String) {
		pasteboard.string = text
	}
}
