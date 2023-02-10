//
//  OnBoardingPageView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-10.
//

import SwiftUI

struct OnBoardingPageView: View {
	enum Page: String, CaseIterable {
		case stayConnected
		case createTribe
		case sendInvites
		case shareTea
		case sendMessages
	}
	var body: some View {
		Text("Hello, World!")
	}
}

struct OnBoardingPageView_Previews: PreviewProvider {
	static var previews: some View {
		OnBoardingPageView()
	}
}
