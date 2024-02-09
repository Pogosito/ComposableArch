//
//  IsPrimeModelView.swift
//  ComposableArch
//
//  Created by Pogosito on 08.02.2024.
//

import SwiftUI

struct IsPrimeModelView: View {

	@ObservedObject var state: AppState

	var body: some View {
		VStack {
			if isPrime(state.count) {
				Text("\(state.count) is prime 🎉")
				if state.favoritePrimes.contains(state.count) {
					Button(action: {
						state.favoritePrimes.removeAll(where: { $0 == state.count })
					}) {
						Text("Remove from favorite primes")
					}
				} else {
					Button(action: { state.favoritePrimes.append(state.count) }) {
						Text("Save to favorite primes")
					}
				}
			} else {
				Text("\(state.count) is not prime :(")
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
