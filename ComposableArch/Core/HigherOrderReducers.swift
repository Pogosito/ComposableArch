//
//  HigherOrderReducers.swift
//  ComposableArch
//
//  Created by Pogosito on 13.02.2024.
//

import Foundation

// Наш reducer будет большим если все засовывать в один метод,
// поэтому сделаем вот такую функцию, чтобы можно
// было разбить функцию reduce на кусочки
func combine<Value, Action>(
	_ reducers: (inout Value, Action) -> Void...
) -> (inout Value, Action) -> Void {

	return { value, action in
		for reduce in reducers {
			reduce(&value, action)
		}
	}
}

// У нас теперь есть возможнось ограничивать у редюсера входящий тип
// и использовать этот метод, чтобы передвать из глобовального сосотояния
// то что нужно (Хочу попробовать с keyPath поиграть)
func pullback<LocalValue, GlobalValue, Action>(
	_ reducer: @escaping (inout LocalValue, Action) -> Void,
	value: WritableKeyPath<GlobalValue, LocalValue>
) -> (inout GlobalValue, Action) -> Void {

	return { globalValue, action in
		reducer(&globalValue[keyPath: value], action)
	}
}


// Тут мы созадали high order reducer, который позволяет добавить
// общую логику для определнных действий, чтобы не дублировать в
// маленьких редьюсерах
func activivtyFeed(
	_ reducer: @escaping (inout AppState, AppAction) -> Void
) -> (inout AppState, AppAction) -> Void {

	return { state, action in
		switch action {
		case .counter: break
		case .primeModal(.removeFavoritePrimeTapped):
			state.activityFeed.append(
				AppState.Activity(
					timestamp: Date(),
					type: .removedFavoritePrime(state.count)
				)
			)
		case .primeModal(.saveFavoritePrimeTapped):
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

func logging<Value, Action>(
	_ reducer: @escaping (inout Value, Action) -> Void
) -> (inout Value, Action) -> Void {

	return { value, action in
		reducer(&value, action)
		print("Action: \(action)")
		print("Value:")
		dump(value)
		print("-----")
	}
}
