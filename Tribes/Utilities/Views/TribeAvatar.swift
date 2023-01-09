//
//  TribeAvatar.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-09.
//

import SwiftUI

struct TribeAvatar: View {
	let members: [TribeMember]
	
	var body: some View {
		Circle()
	}
}

struct TribeAvatar_Previews: PreviewProvider {
	static var previews: some View {
		TribeAvatar(
			members: Array(
				repeating: TribeMember(
					id: UUID().uuidString,
					name: "Kingsley Okeke",
					photoURL: URL(string: "https://megastonksfilestoragedev.blob.core.windows.net/images/001d0c1e-a971-47cd-ad53-eb468e4d3d94.png")!
				),
				count: 10
			)
		)
		.frame(dimension: 200)
	}
}
