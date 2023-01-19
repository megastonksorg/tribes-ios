//
//  UserAvatar.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-18.
//

import SwiftUI

struct UserAvatar: View {
	let url: URL
	var body: some View {
		AsyncImage(url: url,
		content: { image in
			image
				.resizable()
				.scaledToFill()
				.clipShape(Circle())
		}, placeholder: {
			Circle()
				.fill(Color.gray.opacity(0.2))
				.overlay(
					ProgressView()
						.controlSize(.mini)
				)
		})
	}
}

struct UserAvatar_Previews: PreviewProvider {
	static var previews: some View {
		UserAvatar(url: User.noop.profilePhoto)
	}
}
