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
	var viewControllers: [UIHostingController<Page>]
	
	init(currentPage: Binding<Int>, didNotCompleteScroll: @escaping () -> Void, _ views: @escaping () -> [Page]) {
		self._currentPage = currentPage
		self.didNotCompleteScroll = didNotCompleteScroll
		self.viewControllers = views().map { UIHostingController(rootView: $0) }
	}
	
	var body: some View {
		ZStack(alignment: .bottomTrailing) {
			PageViewController(controllers: viewControllers, didNotCompleteScroll: didNotCompleteScroll, currentPage: $currentPage)
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

struct PageViewController: UIViewControllerRepresentable {
	var controllers: [UIViewController]
	var didNotCompleteScroll: () -> Void
	@Binding var currentPage: Int
	
	func makeUIViewController(context: Context) -> UIPageViewController {
		let pageViewController = UIPageViewController(
			transitionStyle: .scroll,
			navigationOrientation: .horizontal
		)
		pageViewController.dataSource = context.coordinator
		pageViewController.delegate = context.coordinator
		for subview in pageViewController.view.subviews {
			if let scrollView = subview as? UIScrollView {
				scrollView.delegate = context.coordinator
				break;
			}
		}
		return pageViewController
	}
	
	func updateUIViewController(_ pageViewController: UIPageViewController, context: Context) {
		pageViewController.setViewControllers(
			[controllers[currentPage]], direction: .forward, animated: true
		)
	}
	
	//MARK: Coordinator
	class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate {
		var parent: PageViewController
		
		init(_ pageViewController: PageViewController) {
			self.parent = pageViewController
		}
		
		func scrollViewDidScroll(_ scrollView: UIScrollView) {
			if (parent.currentPage == 0 && scrollView.contentOffset.x < scrollView.bounds.size.width) {
				scrollView.contentOffset = CGPoint(x: scrollView.bounds.size.width, y: 0);
			} else if (parent.currentPage == parent.controllers.count - 1 && scrollView.contentOffset.x > scrollView.bounds.size.width) {
				scrollView.contentOffset = CGPoint(x: scrollView.bounds.size.width, y: 0);
			}
		}
		
		func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
			if (parent.currentPage == 0 && scrollView.contentOffset.x <= scrollView.bounds.size.width) {
				targetContentOffset.pointee = CGPoint(x: scrollView.bounds.size.width, y: 0);
			} else if (parent.currentPage == parent.controllers.count - 1 && scrollView.contentOffset.x >= scrollView.bounds.size.width) {
				targetContentOffset.pointee = CGPoint(x: scrollView.bounds.size.width, y: 0);
			}
		}
		
		func pageViewController( _ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
			guard let index = parent.controllers.firstIndex(of: viewController) else { return nil }
			if index == 0 {
				return nil
			}
			return parent.controllers[index - 1]
		}

		func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
			guard let index = parent.controllers.firstIndex(of: viewController) else { return nil }
			if index + 1 == parent.controllers.count {
				return nil
			}
			return parent.controllers[index + 1]
		}
		
		func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
			if completed,
				let visibleViewController = pageViewController.viewControllers?.first,
				let index = parent.controllers.firstIndex(of: visibleViewController)
			{
				parent.currentPage = index
			} else {
				parent.didNotCompleteScroll()
			}
		}
	}
	
	func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}
}
