//
//  TribeInviteVM.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-24.
//

import Foundation
import SwiftUI

extension TribeInviteView {
	@MainActor class ViewModel: ObservableObject {
		static private let animationDelay: Double = 2.0
		let codeWords: [String]
		let numberAnimation: Animation = .easeInOut(duration: animationDelay)
		var randomPinTimer: Timer?
		var tribe: Tribe
		
		@Published var code: String = ""
		@Published var pin: Int = 0
		@Published var isCodeReady: Bool = false
		
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
		
		func setPinCode(code: Int) {
			self.randomPinTimer?.invalidate()
			self.randomPinTimer = nil
			withAnimation(numberAnimation) {
				self.pin = code
				self.code = codeWords.randomElement()!
			}
			Task {
				try await Task.sleep(for: .seconds(TribeInviteView.ViewModel.animationDelay))
				withAnimation(.easeInOut) {
					self.isCodeReady = true
				}
			}
		}
		
		func setRandomPinTimer() {
			self.isCodeReady = false
			setRandomPin()
			self.randomPinTimer = Timer.scheduledTimer(
				timeInterval: 1.5,
				target: self,
				selector: #selector(setRandomPin),
				userInfo: nil,
				repeats: true
			)
		}
		
		@objc func setRandomPin() {
			withAnimation(numberAnimation) {
				self.pin = .random(in: 0..<1000000)
			}
		}
	}
}
