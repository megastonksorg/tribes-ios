//
//  MessageVideoView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-03-06.
//

import SwiftUI

struct MessageVideoView: View {
	let model: MessageBodyModel
	
	var body: some View {
		Group {
			if model.message.isEncrypted {
				NoContentView(isShowingErrorTip: false)
			} else {
				if case .video(let url) = model.message.body?.content {
					VideoPlayerView(url: url)
				}
			}
		}
		.ignoresSafeArea()
	}
}

struct MessageVideoView_Previews: PreviewProvider {
	static var previews: some View {
		MessageVideoView(
			model: MessageBodyModel(
				currentTribeMember: TribeMember.noop1,
				sender: nil,
				style: .incoming,
				message: Message.noopEncryptedVideoTea
			)
		)
	}
}
