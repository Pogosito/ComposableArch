//
//  Counter.swift
//  ComposableArch
//
//  Created by Pogosito on 11.02.2024.
//

import Foundation

// У нас теперь есть возможнось ограничивать у редюсера
// входящий тип и использовать этот метод, чтобы передвать из глобовального сосотояния то что нужно (Хочу попробовать с keyPath поиграть)
func pullback<LocalValue, GlobalValue, Action>(
	_ reducer: @escaping (inout LocalValue, Action) -> Void,
	value: WritableKeyPath<GlobalValue, LocalValue>
) -> (inout GlobalValue, Action) -> Void {
	return { globalValue, action in
		reducer(&globalValue[keyPath: value], action)
	}
}

// Предсказание, мне кажется, что мы потом будем делить наше состояние на кусочки
// И для каждого редьюсер будет оперировать своим типом

// (Четко все предсказал будем править)

// Мы не можем просто взять и поменять используемый тип у ридюсера, чтобы типы
// соответсвовались введем новое понятие pullBack (см выше)
func counterReducer(
	state: inout Int,
	action: AppAction
) {
	switch action {
	case .counter(.decrTapped): state -= 1
	case .counter(.incrTapped): state += 1
	default: break
	}
}

func primeModelReducer(
	state: inout AppState,
	action: AppAction
) {
	switch action {
	case .primeModal(.saveFavoritePrimeTapped):
		state.favoritePrimes.append(state.count)
		state.activityFeed.append(
			AppState.Activity(
				timestamp: Date(),
				type: .addedFavoritePrime(state.count)
			)
		)
	case .primeModal(.removeFavoritePrimeTapped):
		state.favoritePrimes.removeAll(where: { $0 == state.count })
		state.activityFeed.append(
			AppState.Activity(
				timestamp: Date(),
				type: .removedFavoritePrime(state.count)
			)
		)
	default: break
	}
}

func favoritePrimesReducer(
	state: inout FavoritePrimesState,
	action: AppAction
) {
	switch action {
	case let .favoritePrimes(.deleteFavoritePrimes(indexSet)):
		for index in indexSet {
			state.favoritePrimes.remove(at: index)
		}
	default: break
	}
}

// Название по подобию с методом reduce берем начальное значение
// и возвращаем новое состояние по дейтсвию, которое задали
//func appReducer(
//	state: inout AppState,
//	action: AppAction
//) {
//	switch action {
//	}
//}

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

var appReducer = combine(
	// Мы берем толькл count b
	pullback(counterReducer, value: \.count),
	primeModelReducer,
	pullback(favoritePrimesReducer, value: \.favoritePrimeState)
)
