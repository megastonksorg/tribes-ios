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
		self.init(detail: error.errorDescription ?? "", type: .error)
	}
}

enum BannerType {
	case info
	case warning
	case success
	case error
	
	var tintColor: Color {
		switch self {
		case .info:
			return .white
		case .success:
			return .green.opacity(tintColorOpacity)
		case .warning:
			return .yellow.opacity(tintColorOpacity)
		case .error:
			return .red.opacity(tintColorOpacity)
		}
	}
}

struct BannerViewModifier: ViewModifier {
	let cornerRadius: CGFloat = 20
	
	@Binding var data: BannerData?
	
	func body(content: Content) -> some View {
		ZStack {
			content
			if let data = data {
				let symbol: String = {
					switch data.type {
					case .info: return "exclamationmark.circle.fill"
					case .success: return "checkmark.circle.fill"
					case .warning: return "exclamationmark.circle.fill"
					case .error: return "x.circle.fill"
					}
				}()
				VStack {
					HStack(alignment: .center){
						VStack {
							if(!data.title.isEmpty){
								Text(data.title)
									.font(Font.app.subTitle)
									.bold()
							}
							
							HStack {
								Image(systemName: symbol)
									.font(Font.app.title)
									.foregroundColor(data.type.tintColor)
								Text(data.detail)
									.font(Font.app.subTitle)
							}
						}
					}
					.foregroundColor(Color.white)
					.padding()
					.gesture(
						DragGesture(minimumDistance: 20, coordinateSpace: .local)
							.onEnded { value in
								let horizontalAmount = value.translation.width as CGFloat
								let verticalAmount = value.translation.height as CGFloat

								if abs(horizontalAmount) < abs(verticalAmount) {
									self.dismissData()
								}
							}


					)
					.background (
						RoundedRectangle(cornerRadius: self.cornerRadius)
							.fill(Color.app.black.opacity(0.6))
					)
					.padding(6)
					
					Spacer()
					
				}
				.onAppear {
					DispatchQueue.main.asyncAfter(deadline: .now() + data.timeOut) {
						self.dismissData()
					}
				}
			}
		}
	}
	
	private func dismissData() {
		self.data = nil
	}
}

struct BannerView_Previews: PreviewProvider {
	static var previews: some View {
		VStack {
			Color.black
				.overlay(
					Text("This is the Banner View")
						.foregroundColor(.white)
				)
		}
		.background(Color.black)
		.banner(data: Binding.constant(BannerData(title: "", detail: "The request was not accepted. Please try again", type: .info)))
	}
}
