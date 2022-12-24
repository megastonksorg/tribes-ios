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
		let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .light)
		impactFeedbackgenerator.prepare()
		impactFeedbackgenerator.impactOccurred()
	}
}
