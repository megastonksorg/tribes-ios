//
//  MessageView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-03-05.
//

import SwiftUI

struct MessageView: View {
	let message: Message
	var body: some View {
		if let body = message.body {
			
		} else {
			
		}
	}
	
	@ViewBuilder
	func encryptedMessageView() -> some View {
		switch message.encryptedBody.content {
		case .text:
			EmptyView()
		default: EmptyView()
		}
	}
}

struct MessageView_Previews: PreviewProvider {
	static var previews: some View {
		MessageView(message: Message.noopEncryptedTextChat)
	}
}
