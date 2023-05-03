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
	
	//Clients
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
						.scaledToFill()
						.overlay(isShown: model.isShowingCaption) {
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
				let cacheKey = Cache.getContentCacheKey(encryptedContent: model.message.encryptedBody.content),
				let imageData = await cacheClient.get(key: cacheKey, type: Data.self),
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
		let modelWithContent: MessageBodyModel = MessageBodyModel(
			currentTribeMember: TribeMember.noop1,
			isShowingCaption: false,
			sender: nil,
			style: .incoming,
			message: Message.noopEncryptedImageChat,
			tribe: Tribe.noop1
		)
		MessageImageView(model: modelWithContent)
		
		MessageImageView(
			model: MessageBodyModel(
				currentTribeMember: TribeMember.noop1,
				isShowingCaption: true,
				sender: nil,
				style: .incoming,
				message: Message.noopEncryptedImageTea,
				tribe: Tribe.noop1
			)
		)
	}
}
