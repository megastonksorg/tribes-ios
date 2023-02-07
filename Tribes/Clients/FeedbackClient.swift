//
//  FeedbackClient.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-08-03.
//

import UIKit

class FeedbackClient {
	static let shared: FeedbackClient = FeedbackClient()
	
	func light() {
		let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
		impactFeedbackGenerator.prepare()
		impactFeedbackGenerator.impactOccurred()
	}
	
	func medium() {
		let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
		impactFeedbackGenerator.prepare()
		impactFeedbackGenerator.impactOccurred()
	}
}
