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
		enum Stage: String {
			case pin
			case code
		}
		
		enum Field: Hashable {
			case pin
			case code
		}
		
		var pageSubtitle: String {
			withAnimation(.interactiveSpring()) {
				"Enter the \(stage.rawValue) that was shared \nwith you below:"
			}
		}
		
		@Published var isJoinButtonEnabled: Bool = false
		@Published var isShowingPasteButton: Bool = false
		@Published var pin: String = ""
		@Published var stage: Stage = .pin
		
		func pinFieldTapped() {
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
					self.pin = String(trimmedString)
				}
			}
		}
	}
}
