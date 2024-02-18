//
//  CounterView.swift
//  ComposableArch
//
//  Created by Pogosito on 08.02.2024.
//

import SwiftUI
import ComposableArchitecture

struct CounterView: View {

	typealias CounterViewState = (count: Int, favoritePrimes: [Int])

	@ObservedObject var store: Store<CounterViewState, AppAction>

	@State private var isPrimeModalShown: Bool = false
	@State private var isAlertNthPrimeShowm: Bool = false
	@State private var alertNthPrime: Int?

	var body: some View {
		VStack {
			HStack {
				Button(action: {
					store.send(.counter(.decrTapped))
				}, label: {
					Text("-")
				})

				Text("\(store.value.count)")

				Button(action: {
					store.send(.counter(.incrTapped))
				}, label: {
					Text("+")
				})
			}

			Button(action: {
				isPrimeModalShown = true
			}, label: {
				Text("Is this prime?")
			})

			Button(action: {
				nthPrime(store.value.count) { prime in
					alertNthPrime = prime
					print("isAlertNthPrimeShowm:", isAlertNthPrimeShowm)
					isAlertNthPrimeShowm = true
				}
			}, label: {
				Text("What is the \(ordinal(store.value.count)) prime?")
			})
		}
		.font(.title)
		.navigationTitle("Counter demo")
		.navigationBarTitleDisplayMode(.large)
		.sheet(
			isPresented: $isPrimeModalShown,
			content: {
				IsPrimeModelView(store: store)
			}
		)
		.alert(
			"Warning",
			isPresented: $isAlertNthPrimeShowm,
			actions: {
				Button {
					print(isAlertNthPrimeShowm)
				} label: {
					Text("Ok")
				}
			}
		) {
			Text(
				"The \(ordinal(store.value.count)) prime is \(alertNthPrime ?? 0)"
			)
		}
	}
}

private extension CounterView {

	func ordinal(_ n: Int) -> String {
		let formatter = NumberFormatter()
		formatter.numberStyle = .ordinal
		return formatter.string(for: n) ?? ""
	}
}

#Preview {
	CounterView(
		store: Store(
			initialValue: AppState(),
			reducer: appReducer
		)
	)
}
