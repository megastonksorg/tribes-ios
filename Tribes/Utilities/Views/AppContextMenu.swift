//
//  AppContextMenu.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-05.
//

import SwiftUI


struct BoundsPreferenceKey: PreferenceKey {
	typealias Value = Anchor<CGRect>?
	
	static var defaultValue: Value? = nil
	
	static func reduce(value: inout Value, nextValue: () -> Value) {
		value = nextValue()
	}
}

struct AppContextMenu<ContextMenu: View>: ViewModifier {
	@State var isShowing: Bool = false
	@ViewBuilder let contextMenu: () -> ContextMenu
	
	func body(content: Content) -> some View {
		content
			.anchorPreference(key: BoundsPreferenceKey.self, value: .bounds) { $0 }
			.onTapGesture {
				self.isShowing = true
			}
			.overlayPreferenceValue(BoundsPreferenceKey.self) { preferenceValues in
				if isShowing {
					GeometryReader { geometry in
						preferenceValues.map {
							Rectangle()
								.fill(Color.black)
								.frame(
									width: geometry[$0].width,
									height: geometry[$0].height
								)
								.offset(
									x: geometry[$0].minX,
									y: geometry[$0].minY
								)
						}
					}
				}
//				preferenceValues.map { value in

//					GeometryReader{ proxy in
//						let rect = proxy[value]
//						content
//							.frame(width: rect.width, height: rect.height)
//							.offset(x: rect.minX, y: rect.maxY > proxy.size.height ? proxy.size.height / 2 : rect.minY)
//					}
//					.transition(.asymmetric(insertion: .identity, removal: .offset(x: 1)))
//				}
			}
			.background {
				if isShowing {
					Rectangle()
						.fill(.ultraThinMaterial)
						.frame(width: UIScreen.main.nativeBounds.maxX, height: UIScreen.main.nativeBounds.maxY)
						.edgesIgnoringSafeArea(.all)
						.onTapGesture {
							self.isShowing = false
						}
				}
			}
	}
}

extension View {
	func appContextMenu<ContentMenu: View>(@ViewBuilder contextMenu: @escaping () -> ContentMenu) -> some View {
		self.modifier(AppContextMenu(contextMenu: contextMenu))
	}
}

struct TestView2: View {
	@State var currentContextId: String = ""
	
	var body: some View {
		VStack {
			Text("He went such dare good mr fact. The small own seven saved man age ﻿no offer. Suspicion did mrs nor furniture smallness. Scale whole downs often leave not eat. An expression reasonably cultivated indulgence mr he surrounded instrument. Gentleman eat and consisted are pronounce distrusts..")
				.padding()
				.background(Color.green)
				.appContextMenu {
					Color.red
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
	}
}

struct AppContextMenu_Previews: PreviewProvider {
	static var previews: some View {
		TestView2()
	}
}
