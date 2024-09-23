//
//  HigherOrderReducers.swift
//  ComposableArch
//
//  Created by Pogosito on 13.02.2024.
//

import Foundation
import ComposableArchitecture

// Тут мы созадали high order reducer, который позволяет добавить
// общую логику для определнных действий, чтобы не дублировать в
// маленьких редьюсерах
func activityFeed(
	_ reducer: @escaping Reducer<
	AppState,
	AppAction,
	AppEnvironment
	>
) -> Reducer<
	AppState,
	AppAction,
	AppEnvironment
> {

	return { state, action, environment in
		switch action {
		case .counterView(.counter),
				.favoritePrimes(.loadedFavoritePrimes),
				.favoritePrimes(.saveButtonTapped),
				.favoritePrimes(.loadButtonTapped): break
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

		return reducer(&state, action, environment)
	}
}
