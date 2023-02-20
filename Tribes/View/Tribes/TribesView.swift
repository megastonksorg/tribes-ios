//
//  TribesView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-15.
//

import SwiftUI
import IdentifiedCollections

struct TribesView: View {
	@Namespace var namespace
	
	@FocusState private var focusedField: ViewModel.FocusField?
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
							TextView(AppConstants.appName, style: .appTitle)
						},
						leading: {
							Button(action: { viewModel.toggleAccountView() }) {
								UserAvatar(url: viewModel.user.profilePhoto)
									.frame(dimension: 50)
									.id(viewModel.user.profilePhoto)
							}
							.buttonStyle(.plain)
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
								Image(systemName: "plus.circle.fill")
									.font(.system(size: 30))
									.foregroundColor(Color.app.secondary)
							})
						}
					)
					.padding(.horizontal)
					
					Spacer()
					
					tribesView()
						.padding(.horizontal)
					
					Spacer()
				}
			}
			.pushOutFrame()
			.banner(data: self.$viewModel.banner)
			.background(Color.app.background)
			.overlay {
				contextMenuBackground()
					.opacity(viewModel.focusedTribe == nil ? 0.0 : 1.0)
					.transition(.opacity)
					.onTapGesture {
						viewModel.setFocusedTribe(nil)
					}
					.overlay(
						VStack {
							Spacer()
							if let focusedTribe = viewModel.focusedTribe {
								let size: CGFloat = 200
								TribeAvatar(
									tribe: focusedTribe,
									size: size,
									showName: false,
									contextAction: { _ in },
									primaryAction: { _ in },
									secondaryAction: { _ in },
									inviteAction: { viewModel.tribeInviteActionTapped($0) },
									leaveAction: { viewModel.tribeLeaveActionTapped($0) }
								)
								.scaleEffect(viewModel.focusedTribe == nil ? 1.0 : 1.1)
								.transition(.scale)
								.matchedGeometryEffect(id: focusedTribe.id, in: namespace, properties: .position)
								
								ZStack {
									let fontSize: CGFloat =  size.getTribeNameSize() + 4
									
									TribeNameView(name: focusedTribe.name, shouldShowEditIcon: true, fontSize: fontSize) {
										viewModel.editTribeName()
									}
									.opacity(viewModel.isEditingTribeName ? 0.0 : 1.0)
									
									if viewModel.isEditingTribeName {
										TextField(
											"",
											text: Binding(
												get: { viewModel.editTribeNameText ?? "" },
												set: { viewModel.setEditTribeNameText($0) }
											)
										)
										.disableAutoCorrection()
										.submitLabel(.done)
										.onSubmit { viewModel.updateTribeName() }
										.font(.system(size: fontSize, weight: .medium, design: .rounded))
										.foregroundColor(Color.app.tertiary)
										.multilineTextAlignment(.center)
										.focused($focusedField, equals: .editTribeName)
										.onAppear { self.focusedField = .editTribeName }
										.onDisappear { viewModel.setEditTribeNameText(nil) }
									}
								}
								.padding(.top)
								.padding(.horizontal, 20)
								
								let padding: CGFloat = 20
								
								VStack(spacing: 10) {
									Group {
										Button(action: { viewModel.tribeInviteActionTapped(focusedTribe) }) {
											HStack {
												Text("Invite")
												Spacer()
												Image(systemName: "person.fill.badge.plus")
											}
										}
										.disabled(focusedTribe.members.count >= 10)
										Rectangle()
											.fill(Color.app.cardStroke)
											.frame(height: 1)
											.padding(.horizontal, -padding)
										Button(action: { viewModel.tribeLeaveActionTapped(focusedTribe) }) {
											HStack {
												Text("Leave")
												Spacer()
												Image(systemName: "rectangle.portrait.and.arrow.forward.fill")
													.offset(x: 4)
											}
										}
									}
									.frame(width: 180)
									.font(.system(size: FontSizes.body))
									.foregroundColor(Color.white)
								}
								.padding(.horizontal, padding)
								.padding(.vertical, padding / 1.5)
								.background {
									ZStack {
										RoundedRectangle(cornerRadius: 10)
											.fill(Color.app.black.opacity(0.6))
										RoundedRectangle(cornerRadius: 10)
											.stroke(Color.app.cardStroke)
									}
								}
								.padding(.horizontal)
								.transition(.asymmetric(insertion: .scale, removal: .identity))
								.opacity(viewModel.isEditingTribeName ? 0.0 : 1.0)
								.animation(.easeInOut, value: viewModel.isEditingTribeName)
							}
							Spacer()
							Spacer()
						}
					)
			}
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
			.sheet(
				isPresented: Binding(
					get: { viewModel.leaveTribeVM != nil },
					set: { $0 == false ? viewModel.setLeaveTribeVM(nil) : () }
				)
			) {
				if let leaveTribeVM = viewModel.leaveTribeVM {
					LeaveTribeView(viewModel: leaveTribeVM)
						.onDisappear { viewModel.loadTribes() }
				}
			}
			.fullScreenCover(
				isPresented: $viewModel.isShowingAccountView
			) {
				AccountView(viewModel: viewModel.accountVM)
			}
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
			.overlay(alignment: .bottomLeading) {
				Image("swipeForCamera")
					.resizable()
					.scaledToFit()
					.frame(height: 100)
			}
		case 1:
			let size: CGFloat = sizeWidth * 0.7
			VStack {
				tribeAvatar(tribe: viewModel.tribes[0], size: size)
			}
		case 2:
			let size: CGFloat = sizeWidth * 0.6
			VStack(spacing: size * 0.4) {
				HStack {
					tribeAvatar(tribe: viewModel.tribes[0], size: size)
					Spacer()
				}
				HStack {
					Spacer()
					tribeAvatar(tribe: viewModel.tribes[1], size: size)
				}
			}
		case 3:
			let size: CGFloat = sizeWidth * 0.5
			VStack {
				HStack {
					tribeAvatar(tribe: viewModel.tribes[0], size: size)
					Spacer()
				}
				HStack {
					Spacer()
					tribeAvatar(tribe: viewModel.tribes[1], size: size)
				}
				HStack {
					tribeAvatar(tribe: viewModel.tribes[2], size: size)
					Spacer()
				}
			}
		case 4:
			let size: CGFloat = sizeWidth * 0.46
			VStack(spacing: size * 0.7) {
				customHStack(
					size: size,
					contentA: {
						tribeAvatar(tribe: viewModel.tribes[0], size: size)
							.offset(y: size * 0.1)
					},
					contentB: {
						tribeAvatar(tribe: viewModel.tribes[1], size: size)
							.offset(y: size * 0.2)
					}
				)
				customHStack(
					size: size,
					contentA: {
						tribeAvatar(tribe: viewModel.tribes[2], size: size)
							.offset(y: -size * 0.1)
					},
					contentB: {
						tribeAvatar(tribe: viewModel.tribes[3], size: size)
							.offset(y: size * 0.1)
					}
				)
				Spacer()
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
		if viewModel.focusedTribe?.id != tribe.id {
			TribeAvatar(
				tribe: tribe,
				size: size,
				contextAction: { viewModel.setFocusedTribe($0) },
				doubleTapAction: { viewModel.tribeDoubleTapped($0) },
				primaryAction: { viewModel.tribePrimaryActionTapped($0) },
				secondaryAction: { viewModel.tribeSecondaryActionTapped($0) },
				inviteAction: { viewModel.tribeInviteActionTapped($0) },
				leaveAction: { viewModel.tribeLeaveActionTapped($0) }
			)
			.id(tribe.id)
			.matchedGeometryEffect(id: tribe.id, in: namespace)
		}
	}
	
	@ViewBuilder
	func contextMenuBackground() -> some View {
		Rectangle()
			.fill(.ultraThinMaterial)
			.overlay {
				Color.app.background.opacity(0.6)
			}
			.edgesIgnoringSafeArea(.all)
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
						Tribe.noop1,
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
