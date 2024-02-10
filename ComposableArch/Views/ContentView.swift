//
//  ContentView.swift
//  ComposableArch
//
//  Created by Pogosito on 08.02.2024.
//

import SwiftUI

struct ContentView: View {

	@ObservedObject var state: AppState

	var body: some View {
		NavigationStack {
			List {
				NavigationLink {
					CounterView(state: state)
				} label: {
					Text("Counter demo")
				}

				NavigationLink {
					FavoritePrimesView(state: state)
				} label: {
					Text("Favorite primes")
				}
			}
		}
	}
}

#Preview {
	ContentView(state: .init())
}
