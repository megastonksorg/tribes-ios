//
//  AppRouter.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-07-16.
//

import Foundation

fileprivate let stackKeyNotification: String = "stack"

@MainActor class AppRouter: ObservableObject {
	enum Route: Hashable {
		enum Stack1: Hashable {
			case createWallet
			case importWallet
			case verifySecretPhrase
			case createProfile(shouldShowHint: Bool, walletAddress: String)
		}
		enum Stack2: Hashable {
		}
		
		case route1(Stack1? = nil)
		case route2(Stack2? = nil)
	}
	
	@Published var stack1: [Route.Stack1] = []
	@Published var stack2: [Route.Stack2] = []
	
	init() {
		NotificationCenter
			.default.addObserver(
				self,
				selector: #selector(handlePushStackRequest),
				name: .pushStack,
				object: nil
			)
		NotificationCenter
			.default.addObserver(
				self,
				selector: #selector(handlePopStackRequest),
				name: .popStack,
				object: nil
			)
		NotificationCenter
			.default.addObserver(
				self,
				selector: #selector(handlePopToRootRequest),
				name: .popToRoot,
				object: nil
			)
	}
	
	private func pushPath(route: Route) {
		switch route {
			case .route1(let route):
				if let route = route { self.stack1.append(route) }
			case .route2(let route):
				if let route = route { self.stack2.append(route) }
		}
	}
	
	private func popPath(route: Route) {
		switch route {
			case .route1: if !self.stack1.isEmpty { self.stack1.removeLast() }
			case .route2: if !self.stack2.isEmpty { self.stack2.removeLast() }
		}
	}
	
	private func popToRoot(route: Route) {
		switch route {
			case .route1: self.stack1 = []
			case .route2: self.stack2 = []
		}
	}
	
	@objc func handlePushStackRequest(notification: NSNotification) {
		if let dict = notification.userInfo as? NSDictionary {
			if let route = dict[stackKeyNotification] as? Route{
				pushPath(route: route)
			}
		}
	}
	
	@objc func handlePopStackRequest(notification: NSNotification) {
		if let dict = notification.userInfo as? NSDictionary {
			if let route = dict[stackKeyNotification] as? Route{
				popPath(route: route)
			}
		}
	}
	
	@objc func handlePopToRootRequest(notification: NSNotification) {
		if let dict = notification.userInfo as? NSDictionary {
			if let route = dict[stackKeyNotification] as? Route{
				popToRoot(route: route)
			}
		}
	}
}

extension AppRouter {
	static func pushStack(stack: AppRouter.Route) {
		let notification = Notification(name: .pushStack, userInfo: [stackKeyNotification: stack])
		
		NotificationCenter.default.post(notification)
	}
	
	static func popStack(stack: AppRouter.Route) {
		let notification = Notification(name: .popStack, userInfo: [stackKeyNotification: stack])
		
		NotificationCenter.default.post(notification)
	}
	
	static func popToRoot(stack: AppRouter.Route) {
		let notification = Notification(name: .popToRoot, userInfo: [stackKeyNotification: stack])
		
		NotificationCenter.default.post(notification)
	}
}
