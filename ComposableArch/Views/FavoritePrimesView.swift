//
//  FavoritePrimesView.swift
//  ComposableArch
//
//  Created by Pogosito on 10.02.2024.
//

import SwiftUI

struct FavoritePrimesView: View {

	@ObservedObject var state: AppState

	var body: some View {
		List {
			ForEach(
				state.favoritePrimes,
				id: \.self
			) { prime in
				Text("\(prime)")
			}
			.onDelete(perform: { indexSet in
				for index in indexSet {
					state.favoritePrimes.remove(at: index)
				}
			})
		}
		.navigationTitle(Text("Favorite Primes"))
	}
}
