//
//  PrimeModal.swift
//  PrimeModal
//
//  Created by Pogosito on 15.02.2024.
//

import SwiftUI
import ComposableArchitecture

public typealias PrimeModalState = (count: Int, favoritePrimes: [Int])

public enum PrimeModalAction: Equatable {
	case saveFavoritePrimeTapped
	case removeFavoritePrimeTapped
}

public func primeModalReducer(
	state: inout PrimeModalState,
	action: PrimeModalAction
) -> [Effect<PrimeModalAction>] {
	switch action {
	case .saveFavoritePrimeTapped:
		state.favoritePrimes.append(state.count)
		return []
	case .removeFavoritePrimeTapped:
		state.favoritePrimes.removeAll(where: { $0 == state.count })
		return []
	}
}

public struct IsPrimeModelView: View {

	@ObservedObject var store: Store<PrimeModalState, PrimeModalAction>

	public init(store: Store<PrimeModalState, PrimeModalAction>) {
		self.store = store
	}

	public var body: some View {
		VStack {
			if isPrime(store.value.count) {
				Text("\(store.value.count) is prime 🎉")
				if store.value.favoritePrimes.contains(store.value.count) {
					Button(action: {
						store.send(.removeFavoritePrimeTapped)
					}) {
						Text("Remove from favorite primes")
					}
				} else {
					Button(action: {
						store.send(.saveFavoritePrimeTapped)
					}) {
						Text("Save to favorite primes")
					}
				}
			} else {
				Text("\(store.value.count) is not prime :(")
			}
		}
	}
}

extension IsPrimeModelView {

	private func isPrime(_ p: Int) -> Bool {
		if p <= 1 { return false }
		if p <= 3 { return true }

		for i in 2...Int(sqrtf(Float(p))) {
			if p % i == 0 { return false }
		}

		return true
	}
}
