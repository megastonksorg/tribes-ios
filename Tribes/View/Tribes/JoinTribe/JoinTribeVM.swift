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
		
		var codeFontSize: CGFloat {
			if code.count > 12 {
				return 30
			} else {
				return 40
			}
		}
		
		var isProceedButtonEnabled: Bool {
			switch stage {
			case .pin: return pin.count == SizeConstants.pinLimit
			case .code: return !code.isEmpty
			}
		}
		
		var isShowingCodeHint: Bool {
			code.isEmpty
		}
		
		var pageSubtitle: String {
			withAnimation(.interactiveSpring()) {
				"Enter the \(stage.rawValue) that was shared \nwith you below:"
			}
		}
		
		var proceedButtonTitle: String {
			switch stage {
			case .pin: return "Next"
			case .code: return "Join Tribe"
			}
		}
		
		@Published var code: String = ""
		@Published var isShowingPasteButton: Bool = false
		@Published var pin: String = ""
		@Published var stage: Stage = .pin
		
		func pasteCode() {
			if let string = UIPasteboard.general.string {
				let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines).prefix(6)
				if trimmedString.rangeOfCharacter(from: NSCharacterSet.decimalDigits.inverted, options: String.CompareOptions.literal, range: nil) == nil {
					self.pin = String(trimmedString)
				}
			}
		}
		
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
		
		func proceed() {
			switch stage {
			case .pin:
				withAnimation(.easeInOut) {
					self.stage = .code
				}
			case .code:
				print("")
			}
		}
	}
}
