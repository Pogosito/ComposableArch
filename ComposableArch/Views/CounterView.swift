//
//  CounterView.swift
//  ComposableArch
//
//  Created by Pogosito on 08.02.2024.
//

import SwiftUI

struct CounterView: View {

	@ObservedObject var state: AppState
	@State private var isPrimeModalShown: Bool = false
	@State private var isAlertNthPrimeShowm: Bool = false
	@Environment(\.dismiss) var dismiss
	@State private var alertNthPrime: Int?

	var body: some View {
		VStack {
			HStack {
				Button(action: {
					state.count -= 1
				}, label: {
					Text("-")
				})

				Text("\(state.count)")

				Button(action: {
					state.count += 1
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
				nthPrime(state.count) { prime in
					alertNthPrime = prime
					print("isAlertNthPrimeShowm:", isAlertNthPrimeShowm)
					isAlertNthPrimeShowm = true
				}
			}, label: {
				Text("What is the \(ordinal(state.count)) prime?")
			})
		}
		.font(.title)
		.navigationTitle("Counter demo")
		.navigationBarTitleDisplayMode(.large)
		.sheet(
			isPresented: $isPrimeModalShown,
			content: {
				IsPrimeModelView(state: state)
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
				"The \(ordinal(state.count)) prime is \(alertNthPrime ?? 0)"
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
	CounterView(state: .init())
}
