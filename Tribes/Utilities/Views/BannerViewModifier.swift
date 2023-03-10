//
//  BannerView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-07-15.
//

import SwiftUI

fileprivate let tintColorOpacity: CGFloat = 0.6

struct BannerData: Equatable {
	var timeOut: CGFloat = 4.0
	var title: String = ""
	var detail: String
	var type: BannerType
}

extension BannerData {
	init(error: AppError.WalletError) {
		self.init(title: error.title, detail: error.errorDescription ?? "", type: .error)
	}
	init(error: AppError.APIClientError) {
		switch error {
		case .httpError(statusCode: let statusCode, data: _):
			if statusCode < 500 {
				self.init(detail: error.errorDescription ?? "", type: .info)
			} else {
				self.init(detail: "", type: .info)
			}
		case .authExpired:
			self.init(detail: "", type: .info)
		case .rawError(let description):
			if description.contains("1001") {
				self.init(detail: "Not connected to the internet", type: .info)
			} else {
				self.init(detail: error.errorDescription ?? "", type: .info)
			}
		default:
			self.init(detail: error.errorDescription ?? "", type: .info)
		}
	}
}
//Code=-1001
enum BannerType {
	case info
	case warning
	case success
	case error
	
	var tintColor: Color { Color.gray }
}

struct BannerViewModifier: ViewModifier {
	let cornerRadius: CGFloat = 20
	
	@Binding var data: BannerData?
	
	@State var isShowing: Bool = false
	
	func body(content: Content) -> some View {
		content
			.overlay(
				Color.clear
					.onChange(of: self.data) { data in
						if data != nil {
							self.showBanner()
						} else {
							self.dismissBanner()
						}
					}
					.safeAreaInset(edge: .top) {
						if let data = data {
							let symbol: String = {
								switch data.type {
								case .info: return "exclamationmark.circle.fill"
								case .success: return "checkmark.circle.fill"
								case .warning: return "exclamationmark.circle.fill"
								case .error: return "x.circle.fill"
								}
							}()
							if isShowing {
								VStack {
									HStack(alignment: .center){
										VStack {
											if(!data.title.isEmpty){
												Text(data.title)
													.font(Font.app.subTitle)
													.bold()
													.lineLimit(1)
											}
											
											if (!data.detail.isEmpty) {
												HStack {
													Image(systemName: symbol)
														.font(Font.app.title)
														.foregroundColor(data.type.tintColor)
													Text(data.detail)
														.font(Font.app.callout)
														.lineLimit(4)
												}
											}
										}
									}
									.foregroundColor(Color.gray)
									.padding()
									.background {
										if !data.title.isEmpty || !data.detail.isEmpty {
											ZStack {
												RoundedRectangle(cornerRadius: self.cornerRadius)
													.fill(Color.app.background)
												RoundedRectangle(cornerRadius: self.cornerRadius)
													.stroke(Color.gray.opacity(0.2), lineWidth: 1)
											}
										}
									}
									.padding(6)
									.scaleEffect(isShowing ? 1.0 : 0.0, anchor: .center)
								}
								.transition(.scale)
								.onAppear {
									DispatchQueue.main.asyncAfter(deadline: .now() + data.timeOut) {
										self.dismissBanner()
									}
								}
							}
						}
					}
			)
	}
	
	private func showBanner() {
		withAnimation(.easeInOut) {
			self.isShowing = true
		}
	}
	
	private func dismissBanner() {
		withAnimation(.easeInOut) {
			self.data = nil
			self.isShowing = false
		}
	}
}

fileprivate struct BannerTestView: View {
	@State var banner: BannerData?
	
	var body: some View {
		VStack {
			Spacer()
			HStack {
				Spacer()
				Button(action: {
					self.banner = BannerData(title: "", detail: "The request was not accepted. Please try again", type: .info)
				}) {
					Text("This is the Banner View")
						.foregroundColor(.white)
				}
				Spacer()
			}
			Spacer()
		}
		.background(Color.black)
		.banner(data: $banner)
	}
}

struct BannerView_Previews: PreviewProvider {
	static var previews: some View {
		VStack {
			BannerTestView()
		}
	}
}
