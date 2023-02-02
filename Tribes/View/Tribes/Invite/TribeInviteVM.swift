//
//  TribeInviteVM.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-24.
//

import Combine
import Foundation
import SwiftUI

extension TribeInviteView {
	@MainActor class ViewModel: ObservableObject {
		static private let animationDelay: Double = 2.0
		
		let codeWords: [String]
		let numberAnimation: Animation = .easeInOut(duration: animationDelay)
		let pinRange: Range<Int> = 0..<1000000
		
		var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
		var randomPinTimer: Timer?
		var tribe: Tribe
		
		var shareSheetItem: String {
			"Join my Tribe. Your secret pin code is \"\(pin)-\(code)\"\n\nIt expires in 5 minutes. \n\nDownload now @ \(AppConstants.website)"
		}
		
		@Published var code: String = ""
		@Published var pin: Int = 0
		@Published var pendingCode: String = ""
		@Published var pendingPin: Int = 0
		
		@Published var didPinCodeGenerationFail: Bool = false
		@Published var isCodeReady: Bool = false
		
		//Clients
		private let apiClient: APIClient = APIClient.shared
		private let walletClient: WalletClient = WalletClient.shared
		
		init(tribe: Tribe) {
			self.codeWords = {
				guard
					 let url = Bundle.main.url(forResource: "CodeWords", withExtension: "json"),
					 let data = try? Data(contentsOf: url),
					 let words = try? JSONDecoder().decode([String].self, from: data)
				else {
					 return []
				}
				return words
			}()
			self.code = codeWords.randomElement()!
			self.tribe = tribe
		}
		
		func didAppear() {
			generatePinCode()
		}
		
		func didDisappear() {
			invalidateTimer()
		}
		
		func setPinCode() {
			invalidateTimer()
			self.didPinCodeGenerationFail = false
			withAnimation(.easeInOut) {
				self.code = self.pendingCode
			}
			withAnimation(numberAnimation) {
				self.pin = self.pendingPin
			}
			Task {
				try await Task.sleep(for: .seconds(TribeInviteView.ViewModel.animationDelay))
				withAnimation(.easeInOut) {
					self.isCodeReady = true
				}
			}
		}
		
		func generatePinCode() {
			invalidateTimer()
			self.isCodeReady = false
			self.didPinCodeGenerationFail = false
			self.pendingPin = .random(in: pinRange)
			self.pendingCode = codeWords.randomElement()!
			simulatePinGeneration()
			validatePendingPinCode()
			self.randomPinTimer = Timer.scheduledTimer(
				timeInterval: 1.5,
				target: self,
				selector: #selector(simulatePinGeneration),
				userInfo: nil,
				repeats: true
			)
		}
		
		private func validatePendingPinCode() {
			guard !self.pendingCode.isEmpty else { return }
			let hashedCode: String = walletClient.hashMessage(message: "\(pendingPin):\(pendingCode)") ?? ""
			self.apiClient
				.inviteToTribe(tribeID: tribe.id, code: hashedCode)
				.receive(on: DispatchQueue.main)
				.sink(
					receiveCompletion: { [weak self] completion in
						switch completion {
						case .finished: return
						case .failure:
							self?.invalidateTimer()
							self?.didPinCodeGenerationFail = true
						}
					}, receiveValue: { [weak self] successResponse in
						if successResponse.success {
							self?.setPinCode()
						} else {
							self?.invalidateTimer()
							self?.didPinCodeGenerationFail = true
						}
					}
				)
				.store(in: &self.cancellables)
		}
		
		private func invalidateTimer() {
			self.randomPinTimer?.invalidate()
			self.randomPinTimer = nil
		}
		
		@objc private func simulatePinGeneration() {
			withAnimation(numberAnimation) {
				self.pin = .random(in: pinRange)
			}
		}
	}
}
