//
//  JoinTribeVM.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-24.
//

import Foundation
import SwiftUI

extension JoinTribeView {
	@MainActor class ViewModel: ObservableObject {
		
		enum Field: Hashable {
			case pin
		}
		
		@Published var code: String = ""
		@Published var isJoinButtonEnabled: Bool = false
		@Published var isShowingPasteButton: Bool = false
		
		func textFieldTapped() {
			Task {
				if !isShowingPasteButton {
					isShowingPasteButton = true
					
					try await Task.sleep(for: .seconds(1.0))
					if isShowingPasteButton {
						isShowingPasteButton = false
					}
				}
				else {
					isShowingPasteButton = false
				}
			}
		}
		
		func pasteCode() {
			if let string = UIPasteboard.general.string {
				let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines).prefix(6)
				if trimmedString.rangeOfCharacter(from: NSCharacterSet.decimalDigits.inverted, options: String.CompareOptions.literal, range: nil) == nil {
					self.code = String(trimmedString)
				}
			}
		}
	}
}
