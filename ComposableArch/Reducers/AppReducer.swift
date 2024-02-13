//
//  Counter.swift
//  ComposableArch
//
//  Created by Pogosito on 11.02.2024.
//

import Foundation

var appReducer = combine(
	// Мы берем толькл count
	pullback(counterReducer, value: \.count),
	primeModalReducer,
	pullback(favoritePrimesReducer, value: \.favoritePrimes)
)

// Мы не можем просто взять и поменять используемый тип у ридюсера, чтобы типы
// соответсвовались введем новое понятие pullBack (см в HigherOrderReducer)
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

func primeModalReducer(
	state: inout AppState,
	action: AppAction
) {
	switch action {
	case .primeModal(.saveFavoritePrimeTapped):
		state.favoritePrimes.append(state.count)
	case .primeModal(.removeFavoritePrimeTapped):
		state.favoritePrimes.removeAll(where: { $0 == state.count })
	default: break
	}
}

func favoritePrimesReducer(
	state: inout [Int],
	action: AppAction
) {
	switch action {
	case let .favoritePrimes(.deleteFavoritePrimes(indexSet)):
		for index in indexSet {
			state.remove(at: index)
		}
	default: break
	}
}
