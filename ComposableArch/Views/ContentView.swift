//
//  ContentView.swift
//  ComposableArch
//
//  Created by Pogosito on 08.02.2024.
//

import SwiftUI
import ComposableArchitecture
import FavoritePrimes

struct ContentView: View {

	@ObservedObject var store: Store<
		AppState,
		AppAction
	>

	var body: some View {
		NavigationStack {
			List {
				NavigationLink {
					CounterView(store: store.view({ ($0.count, $0.favoritePrimes) }))
				} label: {
					Text("Counter demo")
				}

				NavigationLink {
					FavoritePrimesView(store: store.view({ $0.favoritePrimes }))
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
