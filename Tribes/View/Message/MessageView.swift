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
}

struct MessageView_Previews: PreviewProvider {
	static var previews: some View {
		MessageView(message: Message.noopEncryptedTextChat)
	}
}
