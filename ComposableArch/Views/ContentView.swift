//
//  ContentView.swift
//  ComposableArch
//
//  Created by Pogosito on 08.02.2024.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {

	@ObservedObject var store: Store<
		AppState,
		AppAction
	>

	var body: some View {
		NavigationStack {
			List {
				NavigationLink {
					CounterView(store: store)
				} label: {
					Text("Counter demo")
				}

				NavigationLink {
					FavoritePrimesView(store: store)
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
