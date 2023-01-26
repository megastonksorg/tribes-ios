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
		let numberAnimation: Animation = .easeInOut(duration: 2.0)
		var randomNumberTimer: Timer?
		var tribe: Tribe
		
		@Published var code: Int = 0
		@Published var isCopyButtonEnabled: Bool = false
		
		init(tribe: Tribe) {
			self.tribe = tribe
			setRandomNumberTimer()
		}
		
		func setCode(code: Int) {
			self.randomNumberTimer?.invalidate()
			self.randomNumberTimer = nil
			withAnimation(numberAnimation) {
				self.code = code
			}
			Task {
				try await Task.sleep(for: .seconds(2.0))
				withAnimation(.easeInOut) {
					self.isCopyButtonEnabled = true
				}
			}
		}
		
		func setRandomNumberTimer() {
			self.isCopyButtonEnabled = false
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
