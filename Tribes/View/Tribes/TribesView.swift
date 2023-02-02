//
//  TribesView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-15.
//

import SwiftUI
import IdentifiedCollections

struct TribesView: View {
	@StateObject var viewModel: ViewModel
	@State var sizeWidth: CGFloat = UIScreen.main.bounds.maxX > 500 ? 500 :  UIScreen.main.bounds.maxX
	
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
							Menu(content: {
								Button(action: { viewModel.createTribe() }) {
									Label("Create", systemImage: "person.fill.badge.plus")
								}
								Divider()
								Button(action: { viewModel.joinTribe() }) {
									Label("Join", systemImage: "person.2.fill")
								}
							}, label: {
								Button(action: {}) {
									Image(systemName: "plus.circle.fill")
										.font(.system(size: 30))
										.foregroundColor(Color.app.secondary)
								}
							})
						}
					)
					.padding(.horizontal)
					
					tribesView()
						.padding(.horizontal, 30)
					
					Spacer()
				}
				.pushOutFrame()
			}
			.background(Color.app.background)
			.cardView(
				isShowing: $viewModel.isShowingTribeInvite,
				dismissAction: { viewModel.dismissTribeInviteCard() }
			) {
				Group {
					if let inviteVM = viewModel.tribeInviteVM {
						TribeInviteView(
							dismissAction: { viewModel.dismissTribeInviteCard() },
							viewModel: inviteVM
						)
					}
				}
			}
			.banner(data: self.$viewModel.banner)
			.onAppear { viewModel.loadTribes() }
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
		case 1:
			let size: CGFloat = sizeWidth * 0.7
			VStack {
				Spacer()
				tribeAvatar(tribe: viewModel.tribes[0], size: size)
				Spacer()
			}
		case 2:
			let size: CGFloat = sizeWidth * 0.6
			VStack {
				Spacer()
				HStack {
					tribeAvatar(tribe: viewModel.tribes[0], size: size)
					Spacer()
				}
				.padding(.top)
				Spacer()
				HStack {
					Spacer()
					tribeAvatar(tribe: viewModel.tribes[1], size: size)
				}
				Spacer()
			}
		case 3:
			let size: CGFloat = sizeWidth * 0.5
			VStack {
				Spacer()
				HStack {
					tribeAvatar(tribe: viewModel.tribes[0], size: size)
					Spacer()
				}
				.padding(.top)
				HStack {
					Spacer()
					tribeAvatar(tribe: viewModel.tribes[1], size: size)
				}
				HStack {
					tribeAvatar(tribe: viewModel.tribes[2], size: size)
					Spacer()
				}
				Spacer()
			}
		case 4:
			let size: CGFloat = sizeWidth * 0.4
			VStack(spacing: size * 0.4) {
				customHStack(
					size: size,
					contentA: {
						tribeAvatar(tribe: viewModel.tribes[0], size: size)
					},
					contentB: {
						tribeAvatar(tribe: viewModel.tribes[1], size: size)
					}
				)
				.padding(.top)
				customHStack(
					size: size,
					contentA: {
						tribeAvatar(tribe: viewModel.tribes[2], size: size)
					},
					contentB: {
						tribeAvatar(tribe: viewModel.tribes[3], size: size)
					}
				)
			}
		case 5:
			let size: CGFloat = sizeWidth * 0.4
			VStack(spacing: size * 0.4) {
				customHStack(
					size: size,
					contentA: {
						tribeAvatar(tribe: viewModel.tribes[0], size: size)
					},
					contentB: {
						tribeAvatar(tribe: viewModel.tribes[1], size: size)
					}
				)
				customHStack(
					size: size,
					contentA: {
						tribeAvatar(tribe: viewModel.tribes[2], size: size)
					},
					contentB: {
						tribeAvatar(tribe: viewModel.tribes[3], size: size)
					}
				)
				customHStack(
					size: size,
					contentA: {
						tribeAvatar(tribe: viewModel.tribes[4], size: size)
					},
					contentB: {
						EmptyView()
					}
				)
			}
		default:
			let size: CGFloat = sizeWidth * 0.4
			ScrollView(.vertical, showsIndicators: false) {
				LazyVGrid(columns: Array(repeating: GridItem(), count: 2)) {
					ForEach(viewModel.tribes) {
						tribeAvatar(tribe: $0, size: size)
							.padding(.top)
					}
				}
			}
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
	func tribeAvatar(tribe: Tribe, size: CGFloat) -> some View {
		
		TribeAvatar(
			tribe: tribe,
			size: size,
			primaryAction: { viewModel.tribePrimaryActionTapped($0) },
			secondaryAction: { viewModel.tribeSecondaryActionTapped($0) },
			inviteToTribeAction: {_ in},
			leaveAction: { _ in }
		)
	}
	
	@ViewBuilder
	func noTribeImage(name: String, size: CGFloat) -> some View {
		Image(name)
			.resizable()
			.scaledToFill()
			.frame(dimension: size)
	}
	
	@ViewBuilder
	func customHStack<ContentA: View, ContentB: View>(size: CGFloat, contentA: @escaping () -> ContentA, contentB: @escaping () -> ContentB) -> some View {
		HStack {
			contentA()
			Spacer()
			contentB()
				.offset(y: size * 0.5)
		}
	}
}

struct TribesView_Previews: PreviewProvider {
	static var previews: some View {
		VStack { //Need to put the view in a container here to get the animation working correctly in the preview
			let viewModel: TribesView.ViewModel = {
				let tribes = IdentifiedArrayOf(
					uniqueElements: [
						Tribe.noop,
						Tribe.noop2,
						Tribe.noop3,
						Tribe.noop4,
						Tribe.noop5
					]
				)
				let viewModel = TribesView.ViewModel(tribes: tribes, user: User.noop)
				return viewModel
			}()
			TribesView(viewModel: viewModel)
				.preferredColorScheme(.dark)
		}
	}
}
