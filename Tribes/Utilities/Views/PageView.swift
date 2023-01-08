//
//  PageView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-07.
//

import SwiftUI

struct PageView<Content: View>: UIViewControllerRepresentable {
	@Binding var selection: Int
	var isSwitchingPagesEnabled: Bool = true
	var additionalSafeAreaInsets: EdgeInsets = .zero
	let content: () -> [Content]
	
	@Environment(\.layoutDirection) private var layoutDirection
	
	// MARK: UIViewControllerRepresentable
	
	func makeCoordinator() -> Coordinator {
		Coordinator(pageView: self)
	}

	func makeUIViewController(context: Context) -> PagingScrollViewController<Content> {
		let controller = PagingScrollViewController<Content>()
		controller.setupPages(content())
		controller.scrollView.delegate = context.coordinator
		controller.additionalSafeAreaInsets = additionalSafeAreaInsets.uiEdgeInsets(in: layoutDirection)
		return controller
	}
	
	func updateUIViewController(_ uiViewController: PagingScrollViewController<Content>, context: Context) {
		let content = content()
		
		if uiViewController.pages.count != content.count {
			uiViewController.setupPages(content)
		} else {
			for (controller, view) in zip(uiViewController.pages, content) {
				controller.rootView = view
			}
		}
		
		if selection != context.coordinator.page {
			uiViewController.scrollToPage(selection, animated: true)
		}
		
		uiViewController.scrollView.isScrollEnabled = isSwitchingPagesEnabled
		uiViewController.additionalSafeAreaInsets = additionalSafeAreaInsets.uiEdgeInsets(in: layoutDirection)
	}
	
	class Coordinator: NSObject, UIScrollViewDelegate {
		var pageView: PageView
		var page = 0
		
		init(pageView: PageView) {
			self.pageView = pageView
			super.init()
		}
		
		// MARK: UIScrollViewDelegate
		
		func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
			updatePage(for: scrollView)
		}
		
		func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
			updatePage(for: scrollView)
		}
		
		// MARK: Private methods
		
		private func updatePage(for scrollView: UIScrollView) {
			let newPage = Int(scrollView.contentOffset.x / scrollView.frame.width)
			DispatchQueue.main.async {
				self.pageView.selection = newPage
			}
			page = newPage
		}
	}
}

final class PagingScrollViewController<Content: View>: UIViewController {
	var scrollView = UIScrollView()
	var pages: [UIHostingController<Content>] = []
	var additionalInsets = UIEdgeInsets.zero
	
	// MARK: Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		scrollView.backgroundColor = UIColor(Color.black)
		scrollView.isPagingEnabled = true
		scrollView.showsHorizontalScrollIndicator = false
		scrollView.alwaysBounceVertical = false
		scrollView.alwaysBounceHorizontal = false
		scrollView.bounces = false
		view.addSubview(scrollView)
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		scrollView.frame = view.bounds
		scrollView.contentSize = CGSize(
			width: scrollView.frame.width * Double(pages.count),
			height: scrollView.frame.height
		)
		
		var offset = 0.0
		pages.forEach { page in
			page.view.frame = CGRect(
				origin: CGPoint(x: offset, y: scrollView.bounds.origin.y),
				size: scrollView.frame.size
			)
			
			page.additionalSafeAreaInsets = additionalInsets
			
			offset += scrollView.frame.width
		}
	}
	
	// MARK: Public methods
	
	func setupPages(_ pageViews: [Content]) {
		for page in pages {
			page.view.removeFromSuperview()
			page.removeFromParent()
		}
		pages.removeAll(keepingCapacity: true)
		
		for pageView in pageViews {
			let page = UIHostingController(rootView: pageView)
			addChild(page)
			page.willMove(toParent: self)
			scrollView.addSubview(page.view)
			page.didMove(toParent: self)
			page.additionalSafeAreaInsets = additionalInsets
			pages.append(page)
		}
	}
	
	func scrollToPage(_ index: Int, animated: Bool) {
		let offset = scrollView.frame.width * Double(index)
		scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: animated)
	}
}
