//
//  ContentView.swift
//  ComposableArch
//
//  Created by Pogosito on 08.02.2024.
//

import SwiftUI
import ComposableArchitecture
import FavoritePrimes
import Counter

struct ContentView: View {

	@ObservedObject var store: Store<
		AppState,
		AppAction
	>

	var body: some View {
		NavigationStack {
			List {
				NavigationLink {
					CounterView(
						store: store.view(
							value: { ($0.count, $0.favoritePrimes) },
							action: {
								switch $0 {
								case let .counter(action):
									return AppAction.counter(action)
								case let .primeModal(action):
									return AppAction.primeModal(action)
								}
							}
						)
					)
				} label: {
					Text("Counter demo")
				}

				NavigationLink {
					FavoritePrimesView(
						store: store.view(
							value: { $0.favoritePrimes },
							action: { .favoritePrimes($0) }
						)
					)
				} label: {
					Text("Favorite primes")
				}
			}
		}
	}
}

#Preview {
	ContentView(
		store: .init(
			initialValue: AppState(),
			reducer: appReducer
		)
	)
}
