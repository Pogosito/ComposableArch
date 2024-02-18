//
//  FavoritePrimesView.swift
//  ComposableArch
//
//  Created by Pogosito on 10.02.2024.
//

import SwiftUI
import FavoritePrimes
import ComposableArchitecture

struct FavoritePrimesView: View {

	@ObservedObject var store: Store<[Int], AppAction>

	var body: some View {
		List {
			ForEach(
				store.value,
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
