//
//  AppToolBars.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-07-14.
//

import SwiftUI

struct AppToolBar: View {
	enum Position {
		case leading
		case principal
		case trailing
	}
	
	let position: Position
	let principalTitle: String
	let trailingTitle: String
	
	let leadingClosure: () -> ()
	let trailingClosure: () -> ()
	
	init(_ position: Position,
		 principalTitle: String = "",
		 trailingTitle: String = "Done",
		 leadingClosure: @escaping () -> () = {},
		 trailingClosure: @escaping () -> () = {}
	) {
		self.position = position
		self.principalTitle = principalTitle
		self.trailingTitle = trailingTitle
		self.leadingClosure = leadingClosure
		self.trailingClosure = trailingClosure
	}
	
	var body: some View {
		Group {
			switch position {
			case .leading:
				Button(action: { self.leadingClosure() }) {
					Image(systemName: "arrow.left")
				}
			case .principal:
				Text(self.principalTitle)
					.fontWeight(.bold)
			case .trailing:
				Button(action: { self.trailingClosure() }) {
					Text(self.trailingTitle)
				}
			}
		}
		.foregroundColor(.white)
	}
}
