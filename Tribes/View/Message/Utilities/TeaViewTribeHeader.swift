//
//  TeaViewTribeHeader.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-03-23.
//

import IdentifiedCollections
import SwiftUI

struct TeaViewTribeHeader: View {
	let tribe: Tribe
	let timeStamp: Date?
	var body: some View {
		HStack {
			HStack(spacing: -12) {
				ForEach(0..<tribe.members.count, id: \.self) { index in
					UserAvatar(url: tribe.members[index].profilePhoto)
						.frame(dimension: 24)
						.zIndex(-Double(index))
				}
			}
			HStack(spacing: 0) {
				Text("\(tribe.name)")
					.font(Font.app.title3)
					.foregroundColor(Color.app.tertiary)
					.lineLimit(1)
				Text(" • \(timeStamp?.timeAgoDisplay() ?? "")")
					.font(Font.app.body)
					.foregroundColor(Color.app.tertiary)
					.opacity(timeStamp == nil ? 0.0 : 1.0)
			}
		}
	}
}

struct TeaViewTribeHeader_Previews: PreviewProvider {
	static var previews: some View {
		TeaViewTribeHeader(tribe: Tribe.noop2, timeStamp: Date.now)
	}
}
