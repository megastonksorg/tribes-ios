//
//  AppContextMenu.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-05.
//

import SwiftUI


struct BoundsPreferenceKey: PreferenceKey {
	typealias Value = [String: Anchor<CGRect>]
	
	static var defaultValue: Value = [:]
	
	static func reduce(value: inout Value, nextValue: () -> Value) {
		value.merge(nextValue()){$1}
	}
}

struct AppContextMenu<ContextMenu: View>: ViewModifier {
	@Binding var currentMenuId: String?
	@ViewBuilder let contextMenu: () -> ContextMenu
	
	func body(content: Content) -> some View {
		content
			.overlay(isShown: currentMenuId != nil) {
				Rectangle()
					.fill(.ultraThinMaterial)
					.edgesIgnoringSafeArea(.all)
					.onTapGesture {
						self.currentMenuId = nil
					}
			}
			.overlayPreferenceValue(BoundsPreferenceKey.self) { preferenceValues in
				if let currentMenuId = currentMenuId, let preference = preferenceValues.first(where: { item in item.key == currentMenuId }) {
					GeometryReader { geometry in
						let rect = geometry[preference.value]
						contextMenu()
							.frame(width: rect.width, height: rect.height)
							.offset(x: rect.minX, y: rect.minY)
					}
				}
			}
	}
}

extension View {
	func appContextMenu<ContentMenu: View>(currentMenuId: Binding<String?>, @ViewBuilder contextMenu: @escaping () -> ContentMenu) -> some View {
		self.modifier(AppContextMenu(currentMenuId: currentMenuId, contextMenu: contextMenu))
	}
}

struct TestView2: View {
	@State var currentMenuId: String?
	
	var body: some View {
		VStack {
			Text("He went such dare good mr fact. The small own seven saved man age ﻿no offer. Suspicion did mrs nor furniture smallness. Scale whole downs often leave not eat. An expression reasonably cultivated indulgence mr he surrounded instrument. Gentleman eat and consisted are pronounce distrusts..")
				.padding()
				.background(Color.green)
				.anchorPreference(key: BoundsPreferenceKey.self, value: .bounds) { return ["A": $0] }
				.onTapGesture {
					self.currentMenuId = "A"
				}
			Text("He went such dare good mr fact. The small own seven saved man age ﻿no offer. Suspicion did mrs nor furniture smallness. Scale whole downs often leave not eat. An expression reasonably cultivated indulgence mr he surrounded instrument. Gentleman eat and consisted are pronounce distrusts..")
				.padding()
				.background(Color.blue)
				.anchorPreference(key: BoundsPreferenceKey.self, value: .bounds) { return ["B": $0] }
				.onTapGesture {
					self.currentMenuId = "B"
				}
			Text("He went such dare good mr fact. The small own seven saved man age ﻿no offer. Suspicion did mrs nor furniture smallness. Scale whole downs often leave not eat. An expression reasonably cultivated indulgence me he surrounded instrument. Gentleman eat and consisted are pronounce distrusts..")
				.padding()
				.background(Color.yellow)
				.anchorPreference(key: BoundsPreferenceKey.self, value: .bounds) { return ["C": $0] }
				.onTapGesture {
					self.currentMenuId = "C"
				}
			Text("He went such dare good mr fact. The small own seven saved man age ﻿no offer. Suspicion did mrs nor furniture smallness. Scale whole downs often leave not eat. An expression reasonably cultivated indulgence mr he surrounded instrument. Gentleman eat and consisted are pronounce distrusts..")
				.padding()
				.background(Color.red)
				.anchorPreference(key: BoundsPreferenceKey.self, value: .bounds) { return ["D": $0] }
				.onTapGesture {
					self.currentMenuId = "D"
				}
			Text("He went such dare good mr fact. The small own seven saved man age ﻿no offer. Suspicion did mrs nor furniture smallness. Scale whole downs often leave not eat. An expression reasonably cultivated indulgence mr he surrounded instrument. Gentleman eat and consisted are pronounce distrusts..")
				.foregroundColor(Color.white)
				.padding()
				.background(Color.black)
				.anchorPreference(key: BoundsPreferenceKey.self, value: .bounds) { return ["E": $0] }
				.onTapGesture {
					self.currentMenuId = "E"
				}
		}
		.pushOutFrame()
		.background(Color.purple)
		.overlay(Color.clear.id(currentMenuId)) //Need to add this to force the view to refresh when the currentMenuId is set for the first time
		.appContextMenu(currentMenuId: $currentMenuId) {
			switch currentMenuId {
			case "A":
				Text("He went such dare good mr fact. The small own seven saved man age ﻿no offer. Suspicion did mrs nor furniture smallness. Scale whole downs often leave not eat. An expression reasonably cultivated indulgence mr he surrounded instrument. Gentleman eat and consisted are pronounce distrusts..")
					.padding()
					.background(Color.green)
			case "B":
				Text("He went such dare good mr fact. The small own seven saved man age ﻿no offer. Suspicion did mrs nor furniture smallness. Scale whole downs often leave not eat. An expression reasonably cultivated indulgence mr he surrounded instrument. Gentleman eat and consisted are pronounce distrusts..")
					.padding()
					.background(Color.blue)
			case "C":
				Text("He went such dare good mr fact. The small own seven saved man age ﻿no offer. Suspicion did mrs nor furniture smallness. Scale whole downs often leave not eat. An expression reasonably cultivated indulgence mr he surrounded instrument. Gentleman eat and consisted are pronounce distrusts..")
					.padding()
					.background(Color.yellow)
			case "D":
				Text("He went such dare good mr fact. The small own seven saved man age ﻿no offer. Suspicion did mrs nor furniture smallness. Scale whole downs often leave not eat. An expression reasonably cultivated indulgence mr he surrounded instrument. Gentleman eat and consisted are pronounce distrusts..")
					.padding()
					.background(Color.red)
			case "E":
				Text("He went such dare good mr fact. The small own seven saved man age ﻿no offer. Suspicion did mrs nor furniture smallness. Scale whole downs often leave not eat. An expression reasonably cultivated indulgence mr he surrounded instrument. Gentleman eat and consisted are pronounce distrusts..")
					.foregroundColor(Color.white)
					.padding()
					.background(Color.black)
			default:
				EmptyView()
			}
		}
	}
}

struct AppContextMenu_Previews: PreviewProvider {
	static var previews: some View {
		TestView2()
	}
}
