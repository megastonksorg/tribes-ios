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
				noImageView()
					.overlay(
						Image(systemName: AppConstants.encryptedIcon)
							.symbolRenderingMode(.palette)
							.foregroundStyle(Color.app.secondary, Color.white)
							.font(.system(size: 40))
							.dropShadow()
							.dropShadow()
					)
			} else {
				if let uiImage = self.uiImage {
					Image(uiImage: uiImage)
				} else {
					noImageView()
						.overlay(
							Text("Something went wrong. Please try that agaain")
								.font(Font.app.body)
								.foregroundColor(Color.white)
						)
						.dropShadow()
						.dropShadow()
				}
			}
		}
		.ignoresSafeArea()
	}
	
	@ViewBuilder
	func noImageView() -> some View {
		RoundedRectangle(cornerRadius: SizeConstants.imageCornerRadius)
			.fill(Color.black.opacity(0.4))
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
			model.message.body = .init(content: .image("".unwrappedContentUrl), caption: "")
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
