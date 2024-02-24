//
//  FavoritePrimes.swift
//  FavoritePrimes
//
//  Created by Pogosito on 15.02.2024.
//

import SwiftUI
import ComposableArchitecture

public enum FavoritePrimesActions {
	case deleteFavoritePrimes(IndexSet)
}

public func favoritePrimesReducer(
	state: inout [Int],
	action: FavoritePrimesActions
) {
	switch action {
	case let .deleteFavoritePrimes(indexSet):
		for index in indexSet {
			state.remove(at: index)
		}
	}
}

public struct FavoritePrimesView: View {

	@ObservedObject var store: Store<[Int], FavoritePrimesActions>

	public init(
		store: Store<[Int], FavoritePrimesActions>
	) {
		self.store = store
	}

	public var body: some View {
		List {
			ForEach(
				store.value,
				id: \.self
			) { prime in
				Text("\(prime)")
			}
			.onDelete(perform: { indexSet in
				store.send(
					.deleteFavoritePrimes(indexSet)
				)
			})
		}
		.navigationTitle(Text("Favorite Primes"))
	}
}
