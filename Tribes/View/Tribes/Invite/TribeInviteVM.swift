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
		let numberAnimation: Animation = .easeInOut(duration: animationDelay)
		var randomNumberTimer: Timer?
		var tribe: Tribe
		
		@Published var code: Int = 0
		@Published var isCodeReady: Bool = false
		
		init(tribe: Tribe) {
			self.tribe = tribe
		}
		
		func setCode(code: Int) {
			self.randomNumberTimer?.invalidate()
			self.randomNumberTimer = nil
			withAnimation(numberAnimation) {
				self.code = code
			}
			Task {
				try await Task.sleep(for: .seconds(TribeInviteView.ViewModel.animationDelay))
				withAnimation(.easeInOut) {
					self.isCodeReady = true
				}
			}
		}
		
		func setRandomNumberTimer() {
			self.isCodeReady = false
			setRandomNumber()
			self.randomNumberTimer = Timer.scheduledTimer(
				timeInterval: 1.5,
				target: self,
				selector: #selector(setRandomNumber),
				userInfo: nil,
				repeats: true
			)
		}
		
		@objc func setRandomNumber() {
			withAnimation(numberAnimation) {
				self.code = .random(in: 0..<100000)
			}
		}
	}
}
