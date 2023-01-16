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
}

struct TribesView_Previews: PreviewProvider {
	static var previews: some View {
		TribesView(viewModel: .init())
	}
}
