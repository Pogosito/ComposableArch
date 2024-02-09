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
