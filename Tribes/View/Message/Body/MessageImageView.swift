//
//  MessageImageView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-03-06.
//

import SwiftUI

struct MessageImageView: View {
	let model: MessageBodyModel
	let uiImage: UIImage?
	
	init(model: MessageBodyModel) {
		self.model = model
		self.uiImage = {
			if case .image(let imageUrl) = model.message.body?.content {
				guard let data = try? Data(contentsOf: imageUrl) else { return nil }
				return UIImage(data: data)
			}
			return nil
		}()
	}
	
	var body: some View {
		Group {
			if model.message.isEncrypted {
				NoContentView(isEncrypted: true)
			} else {
				if let uiImage = self.uiImage {
					Image(uiImage: uiImage)
						.resizable()
						.scaledToFill()
						.overlay {
							if let caption = model.message.body?.caption {
								Text(caption)
									.styleForCaption()
									.offset(y: SizeConstants.teaCaptionOffset)
							}
						}
				} else {
					NoContentView(isEncrypted: false)
				}
			}
		}
		.ignoresSafeArea()
	}
}

struct MessageImageView_Previews: PreviewProvider {
	static var previews: some View {
		let modelWithContent: MessageBodyModel = {
			let model = MessageBodyModel(
				currentTribeMember: TribeMember.noop1,
				sender: nil,
				style: .incoming,
				message: Message.noopEncryptedImageChat
			)
			model.message.body = .init(content: .image("".unwrappedContentUrl), caption: nil)
			return model
		}()
		MessageImageView(model: modelWithContent)
		
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