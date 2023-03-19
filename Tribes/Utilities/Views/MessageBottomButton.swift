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
		Button(action: { action() }) {
			Image(systemName: style.imagename)
				.font(.system(size: 30))
				.foregroundColor(Color.app.tertiary)
		}
	}
}

struct MessageBottomButton_Previews: PreviewProvider {
	static var previews: some View {
		MessageBottomButton(style: .close) {  }
	}
}
