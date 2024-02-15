//
//  FavoritePrimes.swift
//  FavoritePrimes
//
//  Created by Pogosito on 15.02.2024.
//

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
