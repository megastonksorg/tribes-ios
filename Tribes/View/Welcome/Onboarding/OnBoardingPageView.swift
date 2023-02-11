//
//  OnBoardingPageView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-10.
//

import SwiftUI

struct OnBoardingPageView: View {
	enum Page: String, CaseIterable, Identifiable {
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
		
		var id: String {
			self.rawValue
		}
	}
	
	let page: Page
	
	var body: some View {
		VStack {
			header(page: page)
			Spacer()
			body(page: page)
			Spacer()
			Spacer()
		}
		.overlay(alignment: .bottom) {
			ZStack {
				footer(page: .stayConnected)
					.opacity(0)
				footer(page: page)
			}
		}
	}
	
	@ViewBuilder
	func textView(text: String) -> some View {
		Text(text)
			.font(.system(size: FontSizes.title2, weight: .semibold, design: .rounded))
			.foregroundColor(Color.white.opacity(0.8))
			.multilineTextAlignment(.center)
			.padding(.horizontal)
	}
	
	@ViewBuilder
	func header(page: Page) -> some View {
		HStack {
			Spacer()
			textView(text: page.header)
			Spacer()
		}
	}
	
	@ViewBuilder
	func body(page: Page) -> some View {
		switch page {
		case .stayConnected:
			let padding: CGFloat = -14
			ZStack {
				Circle()
					.fill(Color.app.primary)
					.padding(padding)
				Image("stayConnected")
					.resizable()
					.scaledToFit()
				Circle()
					.stroke(Color.app.secondary, lineWidth: 6)
					.padding(padding)
			}
			.frame(dimension: 240)
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
