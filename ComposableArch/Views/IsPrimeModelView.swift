//
//  IsPrimeModelView.swift
//  ComposableArch
//
//  Created by Pogosito on 08.02.2024.
//

import SwiftUI

struct IsPrimeModelView: View {

	@ObservedObject var store: Store<AppState, AppAction>

	var body: some View {
		VStack {
			if isPrime(store.value.count) {
				Text("\(store.value.count) is prime 🎉")
				if store.value.favoritePrimes.contains(store.value.count) {
					Button(action: {
						store.send(.primeModal(.removeFavoritePrimeTapped))
					}) {
						Text("Remove from favorite primes")
					}
				} else {
					Button(action: {
						store.send(.primeModal(.saveFavoritePrimeTapped))
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
