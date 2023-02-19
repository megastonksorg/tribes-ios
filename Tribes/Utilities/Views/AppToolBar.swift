//
//  AppToolBars.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-07-14.
//

import SwiftUI

struct AppToolBar: View {
	enum Position {
		case principal
		case trailing
	}
	
	let position: Position
	let principalTitle: String
	let trailingTitle: String
	
	let trailingClosure: () -> ()
	
	init(_ position: Position,
		 principalTitle: String = "",
		 trailingTitle: String = "Done",
		 trailingClosure: @escaping () -> () = {}
	) {
		self.position = position
		self.principalTitle = principalTitle
		self.trailingTitle = trailingTitle
		self.trailingClosure = trailingClosure
	}
	
	var body: some View {
		Group {
			switch position {
			case .principal:
				TextView(principalTitle, style: .pageTitle)
			case .trailing:
				Button(action: { self.trailingClosure() }) {
					Text(self.trailingTitle)
						.font(Font.app.title2)
				}
			}
		}
		.foregroundColor(.white)
	}
}
