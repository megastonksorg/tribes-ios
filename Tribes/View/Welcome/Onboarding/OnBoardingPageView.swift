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
		
		var header: String {
			switch self {
			case .stayConnected: return ""
			case .createTribe: return "Step 1"
			case .sendInvites: return "Step 2"
			case .shareTea: return "Step 3"
			case .sendMessages: return "Step 4"
			}
		}
		
		var footer: String {
			switch self {
			case .stayConnected: return "Stay connected with the people who matter the most to you"
			case .createTribe: return "Create a Tribe"
			case .sendInvites: return "Send secure invites to your tribe members"
			case .shareTea: return "Share Tea through the day with your tribe members"
			case .sendMessages: return "Exchange secure messages with your tribe members"
			}
		}
	}
	
	let page: Page
	
	var body: some View {
		VStack {
			header(page: page)
			body(page: page)
			footer(page: page)
		}
	}
	
	@ViewBuilder
	func textView(text: String) -> some View {
		Text(text)
			.font(.system(size: FontSizes.title2, weight: .semibold, design: .rounded))
			.foregroundColor(.white)
			.multilineTextAlignment(.center)
	}
	
	@ViewBuilder
	func header(page: Page) -> some View {
		textView(text: page.header)
	}
	
	@ViewBuilder
	func body(page: Page) -> some View {
		switch page {
		case .stayConnected:
			Color.black
		default:
			EmptyView()
		}
	}
	
	@ViewBuilder
	func footer(page: Page) -> some View {
		textView(text: page.footer)
	}
}

struct OnBoardingPageView_Previews: PreviewProvider {
	static var previews: some View {
		OnBoardingPageView(page: .stayConnected)
			.preferredColorScheme(.dark)
	}
}
