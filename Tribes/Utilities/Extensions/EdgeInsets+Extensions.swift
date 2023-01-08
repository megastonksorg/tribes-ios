//
//  EdgeInsets+Extensions.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-07.
//

import SwiftUI

extension EdgeInsets {
	static let zero = EdgeInsets(uniform: 0)
	
	init(_ edges: Edge.Set, _ space: CGFloat) {
		func inset(for edge: Edge.Set) -> CGFloat {
			return edges.contains(edge) ? space : 0
		}
		
		self.init(
			top: inset(for: .top),
			leading: inset(for: .leading),
			bottom: inset(for: .bottom),
			trailing: inset(for: .trailing)
		)
	}
	
	init(horizontal: CGFloat, vertical: CGFloat = 0) {
		self.init(top: vertical, leading: horizontal, bottom: vertical, trailing: horizontal)
	}
	
	init(vertical: CGFloat) {
		self.init(horizontal: 0, vertical: vertical)
	}
	
	init(uniform inset: CGFloat) {
		self.init(horizontal: inset, vertical: inset)
	}
	
	func uiEdgeInsets(in layoutDirection: LayoutDirection) -> UIEdgeInsets {
		switch layoutDirection {
		case .leftToRight: return UIEdgeInsets(top: top, left: leading, bottom: bottom, right: trailing)
		case .rightToLeft: return UIEdgeInsets(top: top, left: trailing, bottom: bottom, right: leading)
		@unknown default: return UIEdgeInsets(top: top, left: leading, bottom: bottom, right: trailing)
		}
	}
}
