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
		enum WelcomeStack: Hashable {
			case createWallet
			case importWallet
			case verifySecretPhrase
			case createProfile(shouldShowHint: Bool, walletAddress: String)
		}
		enum HomeStack: Hashable {
			case createTribe
			case joinTribe
			case chat(tribe: Tribe)
		}
		
		case welcome(WelcomeStack? = nil)
		case home(HomeStack? = nil)
	}
	
	@Published var welcomeStack: [Route.WelcomeStack] = []
	@Published var homeStack: [Route.HomeStack] = []
	
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
			case .welcome(let route):
				if let route = route { self.welcomeStack.append(route) }
			case .home(let route):
				if let route = route { self.homeStack.append(route) }
		}
	}
	
	private func popPath(route: Route) {
		switch route {
			case .welcome: if !self.welcomeStack.isEmpty { self.welcomeStack.removeLast() }
			case .home: if !self.homeStack.isEmpty { self.homeStack.removeLast() }
		}
	}
	
	private func popToRoot(route: Route) {
		switch route {
			case .welcome: self.welcomeStack = []
			case .home: self.homeStack = []
		}
	}
	
	func setHomeStack(_ stack: [Route.HomeStack]) {
		DispatchQueue.main.async {
			self.homeStack = stack
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
