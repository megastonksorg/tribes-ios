//
//  MnemonicTextView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-06-27.
//

import SwiftUI

struct MnemonicWordView: View {
	var viewHandler: (() -> Void)
	
	@Binding var word: MnemonicWord?
	
	init(word: Binding<MnemonicWord?>, viewHandler: @escaping () -> Void = {}) {
		self._word = word
		self.viewHandler = viewHandler
	}
	
	var body: some View {
		if self.word != nil {
			Button(action: {
				self.viewHandler()
			}) {
				buttonLabel()
			}
			.buttonStyle(AnimatedButtonStyle())
			.disabled(!word!.isSelectable)
		}
	}
	
	@ViewBuilder
	func buttonLabel() -> some View {
		let size = SizeConstants.wordSize
		let cornerRadius: CGFloat = SizeConstants.wordCornerRadius
		let textColor: Color = word!.isAlternateStyle ? .white : .black
		if word!.text.isEmpty {
			RoundedRectangle(cornerRadius: cornerRadius)
				.fill(Color.black)
				.overlay(
					RoundedRectangle(cornerRadius: cornerRadius)
						.stroke(
							word!.isSelected ? Color.app.brown : Color.white.opacity(0.6),
							style: StrokeStyle(
								lineWidth: 1,
								lineCap: .round,
								lineJoin: .miter,
								miterLimit: 4,
								dash: [4],
								dashPhase: 4
							)
						)
				)
				.frame(size: size)
		}
		else {
			Text(word!.text)
				.font(.subheadline)
				.bold()
				.foregroundColor(textColor)
				.minimumScaleFactor(0.6)
				.lineLimit(1)
				.background {
					if word!.isAlternateStyle {
						RoundedRectangle(cornerRadius: cornerRadius)
							.stroke(Color.white, lineWidth: 2)
							.frame(size: size)
					}
					else {
						RoundedRectangle(cornerRadius: cornerRadius)
							.fill(Color.app.brown)
							.frame(size: size)
					}
				}
				.frame(size: size)
		}
	}
}

struct MnemonicWordView_Previews: PreviewProvider {
	static var previews: some View {
		MnemonicWordView(word: Binding.constant(MnemonicWord(text: "", isSelectable: true, isAlternateStyle: false)), viewHandler: {})
			.preferredColorScheme(.dark)
	}
}
