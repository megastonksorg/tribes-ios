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
		
		var isShowingTextHint: Bool {
			text.isEmpty
		}
		
		var isTextValid: Bool {
			!text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
		}
		
		func setBackgroundStyle(style: NoteBackgroundView.Style) {
			withAnimation(.easeInOut) {
				self.backgroundStyle = style
			}
		}
	}
}
