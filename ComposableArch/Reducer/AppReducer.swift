//
//  Counter.swift
//  ComposableArch
//
//  Created by Pogosito on 11.02.2024.
//

// Название по подобию с методом reduce берем начальное значение
// и возвращаем новое состояние по дейтсвию, которое задали
func appReducer(
	state: inout AppState,
	action: AppAction
) {
	switch action {
	case .counter(.decrTapped): state.count -= 1
	case .counter(.incrTapped): state.count += 1
	case .primeModal(.saveFavoritePrimeTapped):
		state.favoritePrimes.removeAll(where: { $0 == state.count })
	case .primeModal(.removeFavoritePrimeTapped):
		state.favoritePrimes.append(state.count)
	case let .favoritePrimes(.deleteFavoritePrimes(indexSet)):
		for index in indexSet {
			state.favoritePrimes.remove(at: index)
		}
	}
}
