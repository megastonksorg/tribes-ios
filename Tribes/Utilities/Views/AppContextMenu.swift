//
//  AppContextMenu.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-05.
//

import SwiftUI


struct BoundsPreferenceKey: PreferenceKey {
	typealias Value = [Anchor<CGRect>]
	
	static var defaultValue: Value = []
	
	static func reduce(value: inout Value, nextValue: () -> Value) {
		value.append(contentsOf: nextValue())
	}
}

struct AppContextMenu<ContextMenu: View>: ViewModifier {
	@Binding var isShowing: Bool
	@ViewBuilder let contextMenu: () -> ContextMenu
	
	func body(content: Content) -> some View {
		content
			.overlay(isShown: isShowing) {
				Rectangle()
					.fill(.ultraThinMaterial)
					.edgesIgnoringSafeArea(.all)
					.onTapGesture {
						self.isShowing = false
					}
			}
			.overlayPreferenceValue(BoundsPreferenceKey.self) { preferenceValues in
				if isShowing {
					GeometryReader { geometry in
						preferenceValues.map {
							contextMenu()
								.frame(
									width: geometry[$0].width,
									height: geometry[$0].height
								)
								.offset(
									x: geometry[$0].minX,
									y: geometry[$0].minY
								)
						}[0]
					}
				}
			}
	}
}

extension View {
	func appContextMenu<ContentMenu: View>(isShowing: Binding<Bool>, @ViewBuilder contextMenu: @escaping () -> ContentMenu) -> some View {
		self.modifier(AppContextMenu(isShowing: isShowing, contextMenu: contextMenu))
	}
}

struct TestView2: View {
	@State var isShowingContextMenu: Bool = false
	@State var currentContextId: String = ""
	
	var body: some View {
		VStack {
			Text("He went such dare good mr fact. The small own seven saved man age ﻿no offer. Suspicion did mrs nor furniture smallness. Scale whole downs often leave not eat. An expression reasonably cultivated indulgence mr he surrounded instrument. Gentleman eat and consisted are pronounce distrusts..")
				.padding()
				.background(Color.green)
				.anchorPreference(key: BoundsPreferenceKey.self, value: .bounds) { [$0] }
				.onTapGesture {
					self.isShowingContextMenu = true
				}
			//			Text("He went such dare good mr fact. The small own seven saved man age ﻿no offer. Suspicion did mrs nor furniture smallness. Scale whole downs often leave not eat. An expression reasonably cultivated indulgence mr he surrounded instrument. Gentleman eat and consisted are pronounce distrusts..")
			//				.padding()
			//				.background(Color.blue)
			//				.appContextMenu {
			//					Color.red
			//				}
		}
		.pushOutFrame()
		.background(Color.purple)
		.appContextMenu(isShowing: $isShowingContextMenu) {
			Text("He went such dare good mr fact. The small own seven saved man age ﻿no offer. Suspicion did mrs nor furniture smallness. Scale whole downs often leave not eat. An expression reasonably cultivated indulgence mr he surrounded instrument. Gentleman eat and consisted are pronounce distrusts..")
				.padding()
				.background(Color.green)
		}
	}
}

struct AppContextMenu_Previews: PreviewProvider {
	static var previews: some View {
		TestView2()
	}
}
