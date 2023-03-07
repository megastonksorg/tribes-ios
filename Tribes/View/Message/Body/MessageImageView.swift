//
//  MessageImageView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-03-06.
//

import SwiftUI

struct MessageImageView: View {
	let model: MessageBodyModel
	
	var body: some View {
		Text("Hello, World!")
	}
}

struct MessageImageView_Previews: PreviewProvider {
	static var previews: some View {
		MessageImageView(
			model: MessageBodyModel(
				currentTribeMember: TribeMember.noop1,
				sender: nil,
				style: .incoming,
				message: Message.noopEncryptedImageTea
			)
		)
	}
}
