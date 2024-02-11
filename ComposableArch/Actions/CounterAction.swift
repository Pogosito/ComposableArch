//
//  CounterAction.swift
//  ComposableArch
//
//  Created by Pogosito on 11.02.2024.
//

// Мы хотим, что все наши изменения состояний происходили в одном месте
// и чтобы мы понимали через какие шаги проходят наши данные перед тем как отобразиться
// чтобы легче находить эти места и чтобы легче понимать что происходит в программе

import Foundation

enum CounterAction {
	case decrTapped
	case incrTapped
}

enum PrimeModalAction {
	case saveFavoritePrimeTapped
	case removeFavoritePrimeTapped
}

enum FavoritePrimesActions {
	case deleteFavoritePrimes(IndexSet)
}

enum AppAction {
	case counter(CounterAction)
	case primeModal(PrimeModalAction)
	case favoritePrimes(FavoritePrimesActions)
}
