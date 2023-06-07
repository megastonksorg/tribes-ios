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
		@Published var focusField: FocusField? = nil
		
		var isShowingTextHint: Bool {
			text.isEmpty
		}
		
		var isTextValid: Bool {
			!text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
		}
		
		var isDoneTyping: Bool {
			focusField == nil && isTextValid
		}
		
		func setFocusedField(_ field: FocusField?) {
			self.focusField = field
		}
		
		func setBackgroundStyle(style: NoteBackgroundView.Style) {
			if style == self.backgroundStyle {
				self.focusField = nil
			} else {
				withAnimation(.easeInOut) {
					self.backgroundStyle = style
				}
			}
		}
	}
}
