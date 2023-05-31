//
//  NoteContentView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-05-29.
//

import SwiftUI

struct NoteContentView: View {
	let style: NoteBackgroundView.Style
	let content: String
	
	@State private var size: CGSize = .zero
	
	var body: some View {
		let textSize: CGFloat = {
			if size.height > 200 {
				return SizeConstants.noteTextSize
			} else {
				return size.height * 0.04
			}
		}()
		NoteBackgroundView(style: style)
			.readSize { self.size = $0 }
			.ignoresSafeArea()
			.overlay(
				Text(content)
					.font(.system(size: textSize, weight: .bold, design: .rounded))
					.foregroundColor(Color.white)
					.multilineTextAlignment(.center)
					.padding(.horizontal)
			)
	}
}

struct NoteContentView_Previews: PreviewProvider {
	static var previews: some View {
		NoteContentView(
			style: .green,
			content: "Hey there, I was wondering if it is okay for me to tell you exactly how I feel. I am sorry if I screwed up. Please forgive me. There is no way you mean that!"
		)
	}
}
