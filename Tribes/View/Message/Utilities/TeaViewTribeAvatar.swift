//
//  TeaViewTribeAvatar.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-03-23.
//

import IdentifiedCollections
import SwiftUI

struct TeaViewTribeAvatar: View {
	let members: IdentifiedArrayOf<TribeMember>
	var body: some View {
		HStack(spacing: -12) {
			ForEach(0..<members.count, id: \.self) { index in
				UserAvatar(url: members[index].profilePhoto)
					.frame(dimension: 24)
					.zIndex(-Double(index))
			}
		}
	}
}

struct TeaViewTribeAvatar_Previews: PreviewProvider {
	static var previews: some View {
		TeaViewTribeAvatar(members: Tribe.noop2.members)
	}
}
