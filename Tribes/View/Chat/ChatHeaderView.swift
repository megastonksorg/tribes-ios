//
//  ChatHeaderView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-21.
//

import IdentifiedCollections
import SwiftUI

struct ChatHeaderView: View {
	enum Context {
		case chat
		case teaPot
	}
	
	let context: Context
	let limit: Int = 10
	let members: IdentifiedArrayOf<TribeMember>
	
	var body: some View {
		let dimension: CGFloat = {
			switch context {
			case .chat: return 36
			case .teaPot: return 40
			}
		}()
		HStack(spacing: -dimension * 0.2) {
			ForEach(members.prefix(limit)) {
				UserAvatar(url: $0.profilePhoto)
					.frame(dimension: dimension)
			}
			if members.count > limit {
				Circle()
					.fill(Color.app.secondary)
					.frame(dimension: dimension)
					.overlay(
						Text("+\(members.count - limit)")
							.font(Font.app.title3)
							.foregroundColor(Color.white)
					)
			}
		}
	}
}

struct ChatHeaderView_Previews: PreviewProvider {
	static var previews: some View {
		NavigationView {
			VStack {
				ChatHeaderView(
					context: .teaPot,
					members: IdentifiedArrayOf(
						uniqueElements:
							[
								TribeMember.noop1,
								TribeMember.noop2,
								TribeMember.noop3,
								TribeMember.noop4,
								TribeMember.noop5,
								TribeMember.noop6,
								TribeMember.noop7,
								TribeMember.noop8,
								TribeMember.noop9
							]
					)
				)
				Spacer()
			}
		}
	}
}
