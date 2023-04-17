//
//  ImportSecretKeyVM.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-07-16.
//

import Combine
import Foundation

extension ImportSecretKeyView {
	@MainActor class ViewModel: ObservableObject {
		
		enum Field: Int, CaseIterable, Hashable, Identifiable {
			case one = 1
			case two = 2
			case three = 3
			case four = 4
			case five = 5
			case six = 6
			case seven = 7
			case eight = 8
			case nine = 9
			case ten = 10
			case eleven = 11
			case twelve = 12
			
			var id: Int {
				return self.rawValue
			}
		}
		
		//Clients
		let apiClient: APIClient = APIClient.shared
		let walletClient: WalletClient = WalletClient.shared
		
		private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
		
		@Published var word1: String = ""
		@Published var word2: String = ""
		@Published var word3: String = ""
		@Published var word4: String = ""
		@Published var word5: String = ""
		@Published var word6: String = ""
		@Published var word7: String = ""
		@Published var word8: String = ""
		@Published var word9: String = ""
		@Published var word10: String = ""
		@Published var word11: String = ""
		@Published var word12: String = ""
		
		@Published var isLoading: Bool = false
		@Published var banner: BannerData?
		
		@Published var focusedField: Field?
		
		var isContinueButtonEnabled: Bool {
			return !self.word1.isEmpty && !self.word2.isEmpty && !self.word3.isEmpty
			&& !self.word4.isEmpty && !self.word5.isEmpty && !self.word6.isEmpty
			&& !self.word7.isEmpty && !self.word8.isEmpty && !self.word9.isEmpty
			&& !self.word10.isEmpty && !self.word11.isEmpty && !self.word12.isEmpty
		}
		
		func advanceToNextField() {
			guard let currentField = self.focusedField?.rawValue else { return }
			if self.focusedField != .twelve {
				let nextField = Field(rawValue: currentField + 1)
				let shouldNavigate: Bool = {
					switch nextField {
					case .two: return self.word2.isEmpty
					case .three: return self.word3.isEmpty
					case .four: return self.word4.isEmpty
					case .five: return self.word5.isEmpty
					case .six: return self.word6.isEmpty
					case .seven: return self.word7.isEmpty
					case .eight: return self.word8.isEmpty
					case .nine: return self.word9.isEmpty
					case .ten: return self.word10.isEmpty
					case .eleven: return self.word11.isEmpty
					case .twelve: return self.word12.isEmpty
					default: return false
					}
				}()
				if shouldNavigate { self.focusedField = nextField }
			}
		}
		
		func resetWordFields() {
			self.word1 = ""
			self.word2 = ""
			self.word3 = ""
			self.word4 = ""
			self.word5 = ""
			self.word6 = ""
			self.word7 = ""
			self.word8 = ""
			self.word9 = ""
			self.word10 = ""
			self.word11 = ""
			self.word12 = ""
		}
		
		func importWallet() {
			let mnemonic: String = [
				self.word1, self.word2, self.word3, self.word4, self.word5, self.word6,
				self.word7, self.word8, self.word9, self.word10, self.word11, self.word12
			].map{ $0.trimmingCharacters(in: .whitespacesAndNewlines) }.joined(separator: " ")
			
			switch walletClient.importWallet(mnemonic: mnemonic) {
			case .success(let hdWallet):
				self.walletClient.saveMnemonic(mnemonic: mnemonic)
				self.isLoading = true
				let address = self.walletClient.getAddress(hdWallet)
				self.apiClient.doesAccountExist(for: address)
					.receive(on: DispatchQueue.main)
					.sink(receiveCompletion: { completion in
						switch completion {
						case .finished: return
						case .failure(let error):
							self.isLoading = false
							self.banner = BannerData(error: error)
						}
					}, receiveValue: { response in
						self.isLoading = false
						if response.success {
							let user: User = User(
								walletAddress: address,
								fullName: "",
								profilePhoto: URL(string: "https://tribesapp.ca")!,
								currency: "USD",
								acceptTerms: true,
								isOnboarded: true
							)
							//Ask the user to login here
							AppState.updateAppState(with: .changeAppMode(.authentication(AuthenticateView.ViewModel(context: .signIn, user: user))))
						}
						else {
							//Take the user to the Account Creation Screen
							AppRouter.pushStack(stack: .welcome(.createProfile(shouldShowHint: true, walletAddress: address)))
						}
					})
					.store(in: &cancellables)
			case .failure(let error):
				self.banner = BannerData(error: error)
				return
			}
		}
		
		func pushView() {
			AppRouter.pushStack(stack: .welcome(.importWallet))
		}
	}
}
