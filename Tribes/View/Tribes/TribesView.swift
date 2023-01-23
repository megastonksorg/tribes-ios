//
//  TribesView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-15.
//

import SwiftUI

struct TribesView: View {
	
	@StateObject var viewModel: ViewModel
	
	init(viewModel: ViewModel) {
		self._viewModel = StateObject(wrappedValue: viewModel)
	}
	
	var body: some View {
		VStack {
			VStack {
				SymmetricHStack(
					content: {
						TextView("Tribes", style: .appTitle)
					},
					leading: {
						Button(action: {  }) {
							UserAvatar(url: viewModel.user.profilePhoto)
								.frame(dimension: 50)
						}
						.buttonStyle(.insideScaling)
					},
					trailing: {
						Button(action: {}) {
							Image(systemName: "plus.circle.fill")
								.font(.system(size: 30))
								.foregroundColor(Color.app.secondary)
						}
						.buttonStyle(.insideScaling)
					}
				)
				
				tribesView()
				
				Spacer()
			}
			.padding(.horizontal)
		}
		.pushOutFrame()
		.background(Color.app.background)
	}
	
	@ViewBuilder
	func tribesView() -> some View {
		switch viewModel.tribes.count {
		case 0:
			let fillColor: Color = Color.app.secondary.opacity(0.5)
			let firstCircleWidth: CGFloat = 40
			let strokeColor: Color = Color.app.secondary
			VStack {
				Spacer()
				ZStack {
					noTribeCircle(size: 120, fillColor, strokeColor)
						.opacity(0.4)
					noTribeCircle(size: 90, fillColor, strokeColor)
						.opacity(0.6)
					noTribeCircle(size: 60, fillColor, strokeColor)
						.opacity(0.8)
					Circle()
						.fill(fillColor)
						.frame(dimension: firstCircleWidth)
						.overlay(
							Circle()
								.stroke(strokeColor)
								.overlay(
									Image(systemName: "plus")
										.foregroundColor(.black)
										.font(.system(size: 18, design: .rounded))
								)
						)
					HStack {
						noTribeImage(name: "left3", size: 35)
						noTribeImage(name: "left2", size: 40)
						noTribeImage(name: "left1", size: 45)
						Spacer()
							.frame(width: firstCircleWidth + 10)
						noTribeImage(name: "right1", size: 45)
						noTribeImage(name: "right2", size: 40)
						noTribeImage(name: "right3", size: 35)
					}
				}
				
				Text("Create Your First Tribe")
					.font(Font.app.title2)
					.foregroundColor(Color.app.tertiary)
				Text("Remember the tea and messages you share with your tribe members are private and encrypted. \nNo one can view or read them. Not even us! \n\nTo get started, tap the (+) above!")
					.multilineTextAlignment(.center)
					.font(Font.app.footnote)
					.foregroundColor(Color.app.tertiary)
					.padding(.top, 2)
				Spacer()
			}
		default:
			HStack {
				Button(action: {}) {
					TribeAvatar(
						tribe: Tribe(
							id: "1",
							name: "The boys",
							members: Array(repeating: TribeMember.noop, count: 4)
						),
						size: 200
					)
				}
				.buttonStyle(.insideScaling)
			}
			.padding(.top, 20)
		}
	}
	
	@ViewBuilder
	func noTribeCircle(size: CGFloat, _ fillColor: Color, _ strokeColor: Color) -> some View {
		Circle()
			.fill(
				LinearGradient(colors: [fillColor.opacity(0.6), fillColor], startPoint: .leading, endPoint: .trailing)
			)
			.frame(dimension: size)
			.overlay(
				Circle()
					.stroke(strokeColor)
			)
	}
	
	@ViewBuilder
	func noTribeImage(name: String, size: CGFloat) -> some View {
		Image(name)
			.resizable()
			.scaledToFill()
			.frame(dimension: size)
	}
}

struct TribesView_Previews: PreviewProvider {
	static var previews: some View {
		TribesView(viewModel: .init(user: User.noop))
	}
}
