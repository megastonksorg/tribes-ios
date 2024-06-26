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
		let isSmallSize: Bool = size.height < 300
		let textSize: CGFloat = {
			if isSmallSize {
				return size.height * 0.035
			} else {
				return SizeConstants.noteTextSize
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
					.frame(maxWidth: self.size.width * 0.8)
			)
	}
}

extension NoteContentView {
	init(url: URL, content: String) {
		self.style = {
			let defaultStyle: NoteBackgroundView.Style = NoteBackgroundView.Style.allCases.randomElement() ?? .green
			guard
				let backgroundValue = url[AppConstants.noteBackgroundKey],
				let style = NoteBackgroundView.Style(rawValue: backgroundValue)
			else { return defaultStyle }
			return style
		}()
		self.content = content
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
