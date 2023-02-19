//
//  PageView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-07.
//

import SwiftUI
import UIKit

struct PageView<Page: View>: View {
	let isShowingControl: Bool = false
	
	@Binding var currentPage: Int
	var didNotCompleteScroll: () -> Void
	var viewControllers: [Page]
	
	init(currentPage: Binding<Int>, didNotCompleteScroll: @escaping () -> Void, _ views: @escaping () -> [Page]) {
		self._currentPage = currentPage
		self.didNotCompleteScroll = didNotCompleteScroll
		self.viewControllers = views()
	}
	
	var body: some View {
		ZStack(alignment: .bottomTrailing) {
			PageViewController(pages: viewControllers, didNotCompleteScroll: didNotCompleteScroll, currentPage: $currentPage)
			if isShowingControl {
				PageControl(numberOfPages: viewControllers.count, currentPage: $currentPage)
					.padding(.trailing)
			}
		}
	}
}

struct PageControl: UIViewRepresentable {
	var numberOfPages: Int
	@Binding var currentPage: Int
	
	func makeUIView(context: Context) -> UIPageControl {
		let control = UIPageControl()
		control.numberOfPages = numberOfPages
		control.addTarget(
			context.coordinator,
			action: #selector(Coordinator.updateCurrentPage(sender:)),
			for: .valueChanged
		)
		return control
	}
	
	func updateUIView(_ uiView: UIPageControl, context: Context) {
		uiView.currentPage = currentPage
	}
	
	class Coordinator: NSObject {
		init(_ control: PageControl) {
			self.control = control
		}
		
		var control: PageControl
		
		@objc func updateCurrentPage(sender: UIPageControl) {
			control.currentPage = sender.currentPage
		}
	}
	
	func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}
}

struct PageViewController<Page: View>: UIViewControllerRepresentable {
	
	var pages: [Page]
	var didNotCompleteScroll: () -> Void
	
	
	@Binding var currentPage: Int
	
	func makeUIViewController(context: Context) -> UIPageViewController {
		let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
		pageViewController.dataSource = context.coordinator
		pageViewController.delegate = context.coordinator
		return pageViewController
	}
	
	func updateUIViewController(_ pageViewController: UIPageViewController, context: Context) {
		var direction: UIPageViewController.NavigationDirection = .forward
		var animated: Bool = false
		
		if let previousViewController = pageViewController.viewControllers?.first,
		   let previousPage = context.coordinator.controllers.firstIndex(of: previousViewController) {
			direction = (currentPage >= previousPage) ? .forward : .reverse
			animated = (currentPage != previousPage)
		}
		
		let currentViewController = context.coordinator.controllers[currentPage]
		pageViewController.setViewControllers([currentViewController], direction: direction, animated: animated)
		for subview in pageViewController.view.subviews {
			if let scrollView = subview as? UIScrollView {
				scrollView.delegate = context.coordinator
				break;
			}
		}
	}
	
	func makeCoordinator() -> Coordinator {
		return Coordinator(parent: self, pages: pages)
	}
	
	class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate {
		
		var parent: PageViewController
		var controllers: [UIViewController]
		
		init(parent: PageViewController, pages: [Page]) {
			self.parent = parent
			self.controllers = pages.map { UIHostingController(rootView: $0) }
		}
		
		func scrollViewDidScroll(_ scrollView: UIScrollView) {
			if (parent.currentPage == 0 && scrollView.contentOffset.x < scrollView.bounds.size.width) {
				scrollView.contentOffset = CGPoint(x: scrollView.bounds.size.width, y: 0);
			} else if (parent.currentPage == controllers.count - 1 && scrollView.contentOffset.x > scrollView.bounds.size.width) {
				scrollView.contentOffset = CGPoint(x: scrollView.bounds.size.width, y: 0);
			}
		}
		
		func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
			if (parent.currentPage == 0 && scrollView.contentOffset.x <= scrollView.bounds.size.width) {
				targetContentOffset.pointee = CGPoint(x: scrollView.bounds.size.width, y: 0);
			} else if (parent.currentPage == controllers.count - 1 && scrollView.contentOffset.x >= scrollView.bounds.size.width) {
				targetContentOffset.pointee = CGPoint(x: scrollView.bounds.size.width, y: 0);
			}
		}
		
		func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
			guard let index = controllers.firstIndex(of: viewController) else {
				return nil
			}
			if index == 0 {
				return nil
			}
			return controllers[index - 1]
		}
		
		func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
			guard let index = controllers.firstIndex(of: viewController) else {
				return nil
			}
			if index + 1 == controllers.count {
				return nil
			}
			return controllers[index + 1]
		}
		
		func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
			if completed,
			   let currentViewController = pageViewController.viewControllers?.first,
			   let currentIndex = controllers.firstIndex(of: currentViewController)
			{
				parent.currentPage = currentIndex
			} else {
				parent.didNotCompleteScroll()
			}
		}
	}
}
