//
//  MessageImageView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-03-06.
//

import SwiftUI

struct MessageImageView: View {
	let model: MessageBodyModel
	@State var uiImage: UIImage?
	@State var isLoadingImage: Bool = true
	
	//Client
	let cacheClient: CacheClient = CacheClient.shared
	
	init(model: MessageBodyModel) {
		self.model = model
	}
	
	var body: some View {
		Group {
			if model.message.isEncrypted {
				NoContentView(isEncrypted: true)
			} else {
				if isLoadingImage {
					LoadingIndicator(speed: 0.4)
						.frame(dimension: SizeConstants.loadingIndicatorSize)
				} else if let uiImage = self.uiImage {
					Image(uiImage: uiImage)
						.resizable()
						.scaledToFit()
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
		.task {
			if uiImage == nil {
				loadImage()
			}
		}
	}
	
	func loadImage() {
		Task {
			guard
				self.uiImage == nil,
				let cacheKey = Cache.getCacheKey(encryptedContent: model.message.encryptedBody.content),
				let imageData = await CacheClient.shared.get(key: cacheKey, type: Data.self),
				let uiImage = UIImage(data: imageData)
			else {
				self.isLoadingImage = false
				return
			}
			self.uiImage = uiImage
			self.isLoadingImage = false
		}
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
