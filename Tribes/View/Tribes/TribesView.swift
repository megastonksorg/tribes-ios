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
						Button(action: {}) {
							Circle()
								.fill(Color.gray)
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
						.frame(dimension: 40)
						.overlay(
							Circle()
								.stroke(strokeColor)
								.overlay(
									Image(systemName: "plus")
										.font(.system(size: 18, design: .rounded))
								)
						)
				}
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
}

struct TribesView_Previews: PreviewProvider {
	static var previews: some View {
		TribesView(viewModel: .init())
	}
}
