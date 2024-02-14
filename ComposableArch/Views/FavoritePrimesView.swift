//
//  FavoritePrimesView.swift
//  ComposableArch
//
//  Created by Pogosito on 10.02.2024.
//

import SwiftUI
import ComposableArchitecture

struct FavoritePrimesView: View {

	@ObservedObject var store: Store<AppState, AppAction>

	var body: some View {
		List {
			ForEach(
				store.value.favoritePrimes,
				id: \.self
			) { prime in
				Text("\(prime)")
			}
			.onDelete(perform: { indexSet in
				store.send(.favoritePrimes(.deleteFavoritePrimes(indexSet)))
			})
		}
		.navigationTitle(Text("Favorite Primes"))
	}
}
