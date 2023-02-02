//
//  JoinTribeVM.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-24.
//

import Combine
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
		
		private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
		
		@Published var code: String = ""
		@Published var pin: String = ""
		@Published var stage: Stage = .pin
		@Published var isLoading: Bool = true
		@Published var isShowingPasteButton: Bool = false
		@Published var banner: BannerData?
		
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
		
		//Clients
		let apiClient: APIClient = APIClient.shared
		
		init() {
			
		}
		
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
				self.isLoading = true
				self.apiClient
					.joinTribe(pin: self.pin, code: self.code)
					.receive(on: DispatchQueue.main)
					.sink(
						receiveCompletion: { [weak self] completion in
							switch completion {
							case .finished: return
							case .failure(let error):
								self?.isLoading = false
								self?.banner = BannerData(error: error)
						}
						}, receiveValue: { _ in
							
						}
					)
					.store(in: &cancellables)
			}
		}
		
		func setStage(stage: Stage) {
			withAnimation(.easeInOut) {
				self.stage = stage
			}
		}
	}
}
