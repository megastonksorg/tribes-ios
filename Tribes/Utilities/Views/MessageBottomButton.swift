//
//  MessageBottomButton.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-03-18.
//

import SwiftUI

struct MessageBottomButton: View {
	enum Style {
		case close
		case send
		
		var imagename: String {
			switch self {
			case .close: return "xmark.circle.fill"
			case .send: return "paperplane.circle.fill"
			}
		}
	}
	
	let style: Style
	let action: () -> Void
	
	var body: some View {
		let size: CGFloat = {
			switch style {
			case .close: return 40
			case .send: return 24
			}
		}()
		Button(action: { action() }) {
			ZStack {
				Circle()
					.fill(Color.white)
					.frame(dimension: size * 0.8)
				Image(systemName: style.imagename)
					.font(.system(size: size))
					.foregroundColor(Color.app.secondary)
			}
		}
		.buttonStyle(.bright)
	}
}

struct MessageBottomButton_Previews: PreviewProvider {
	static var previews: some View {
		MessageBottomButton(style: .close) {  }
	}
}
