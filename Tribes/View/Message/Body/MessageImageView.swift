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
		if model.message.isEncrypted {
			RoundedRectangle(cornerRadius: SizeConstants.imageCornerRadius)
				.fill(Color.gray.opacity(0.2))
				.overlay(
					Image(systemName: AppConstants.encryptedIcon)
						.symbolRenderingMode(.palette)
						.foregroundStyle(Color.app.secondary, Color.white)
						.font(.system(size: 30))
				)
		}
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
