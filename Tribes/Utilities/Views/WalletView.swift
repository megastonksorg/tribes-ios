//
//  WalletView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-12.
//

import SwiftUI

struct WalletView: View {
	let address: String
	let copyAction: () -> ()
	
	var body: some View {
		VStack(spacing: 4) {
			ExpandedHStack {
				Text("ETHEREUM")
					.font(Font.app.footnote)
					.foregroundColor(.gray)
			}
			
			ExpandedHStack {
				Text(String(stringLiteral: "$_,_ _ _._ _ USD"))
					.font(Font.app.title3)
					.fontWeight(.semibold)
					.foregroundColor(.white)
					.overlay {
						Text(String(stringLiteral: " * * * * * *"))
							.offset(x: -18)
					}
			}
			
			ExpandedHStack {
				Text("WALLET ADDRESS")
					.font(Font.app.footnote)
					.foregroundColor(.gray)
			}
			.padding(.top, 30)
			
			HStack {
				Text(address)
					.font(Font.app.title3)
					.fontWeight(.semibold)
					.foregroundColor(.white)
				
				Spacer()
				
				Button(action: { copyAction() }) {
					Image(systemName: "doc.on.doc.fill")
				}
			}
		}
		.foregroundColor(.white)
		.multilineTextAlignment(.leading)
		.lineLimit(1)
		.padding()
		.background(TextFieldBackgroundView())
	}
}

fileprivate struct ExpandedHStack<Content: View>: View {
	@ViewBuilder var content: Content
	
	init(@ViewBuilder content: @escaping () -> Content) {
		self.content = content()
	}
	
	var body: some View {
		HStack {
			content
			Spacer()
		}
	}
}

struct WalletView_Previews: PreviewProvider {
	static var previews: some View {
		WalletView(address: "0X245673902389YYDGAS123", copyAction: {})
	}
}
