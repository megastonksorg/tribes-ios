//
//  NoteContentView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-05-29.
//

import SwiftUI

struct NoteContentView: View {
	var body: some View {
		NoteBackgroundView(style: .orange)
			.ignoresSafeArea()
	}
}

struct NoteContentView_Previews: PreviewProvider {
	static var previews: some View {
		NoteContentView()
	}
}
