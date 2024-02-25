//
//  HigherOrderReducers.swift
//  ComposableArch
//
//  Created by Pogosito on 13.02.2024.
//

import Foundation

// Тут мы созадали high order reducer, который позволяет добавить
// общую логику для определнных действий, чтобы не дублировать в
// маленьких редьюсерах
func activivtyFeed(
	_ reducer: @escaping (inout AppState, AppAction) -> Void
) -> (inout AppState, AppAction) -> Void {

	return { state, action in
		switch action {
		case .counterView(.counter): break
		case .counterView(.primeModal(.removeFavoritePrimeTapped)):
			state.activityFeed.append(
				AppState.Activity(
					timestamp: Date(),
					type: .removedFavoritePrime(state.count)
				)
			)
		case .counterView(.primeModal(.saveFavoritePrimeTapped)):
			state.activityFeed.append(
				AppState.Activity(
					timestamp: Date(),
					type: .addedFavoritePrime(state.count)
				)
			)
		case let .favoritePrimes(.deleteFavoritePrimes(IndexSet)):
			for index in IndexSet {
				state.activityFeed.append(
					.init(
						timestamp: Date(),
						type: .removedFavoritePrime(
							state.favoritePrimes[index]
						)
					)
				)
			}
		}

		reducer(&state, action)
	}
}
