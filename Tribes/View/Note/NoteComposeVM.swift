//
//  NoteComposeVM.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-05-31.
//

import Foundation
import SwiftUI

extension NoteComposeView {
	@MainActor class ViewModel: ObservableObject {
		enum FocusField: Hashable {
			case text
		}
		
		@Published var backgroundStyle: NoteBackgroundView.Style = NoteBackgroundView.Style.allCases.randomElement() ?? .green
		@Published var text: String = ""
		
		
		func setBackgroundStyle(style: NoteBackgroundView.Style) {
			withAnimation(.easeInOut) {
				self.backgroundStyle = style
			}
		}
	}
}
