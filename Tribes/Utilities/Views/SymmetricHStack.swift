//
//  SymmetricHStack.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-12.
//

import SwiftUI

struct SymmetricHStack<Content: View, Leading: View, Trailing: View>: View {
	var alignment = VerticalAlignment.center
	var spacing: CGFloat?
	
	@ViewBuilder var content: () -> Content
	@ViewBuilder var leading: () -> Leading
	@ViewBuilder var trailing: () -> Trailing
	
	init(
		alignment: SwiftUI.VerticalAlignment = VerticalAlignment.center,
		spacing: CGFloat? = nil,
		content: @escaping () -> Content,
		leading: @escaping () -> Leading,
		trailing: @escaping () -> Trailing
	) {
		self.alignment = alignment
		self.spacing = spacing
		self.content = content
		self.leading = leading
		self.trailing = trailing
	}
	
	var body: some View {
		HStack(alignment: alignment, spacing: spacing) {
			ZStack(alignment: .leading) {
				trailing().hidden()
				leading()
			}
			
			Spacer(minLength: 0)
			
			content()
			
			Spacer(minLength: 0)
			
			ZStack(alignment: .trailing) {
				leading().hidden()
				trailing()
			}
		}
	}
}
struct SymmetricHStack_Previews: PreviewProvider {
	static var previews: some View {
		SymmetricHStack(
			content: {
			Circle()
		}, leading: {
			Circle()
		}, trailing: {
			Circle()
		})
	}
}
