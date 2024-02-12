//
//  AppState.swift
//  ComposableArch
//
//  Created by Pogosito on 08.02.2024.
//

import SwiftUI

// Почему использовать value семантику для состояния приложения лучше чем реф ? 
// Нашел интересное утверждение: Value SEMANTICS (not value types!) хочу понять в чем смысл
struct AppState {

	var count = 0

	var favoritePrimes: [Int] = []

	var activityFeed: [Activity] = []

	struct Activity {

		let timestamp: Date

		let type: ActivityType
	}

	enum ActivityType {

		case addedFavoritePrime(Int)

		case removedFavoritePrime(Int)
	}
}

// Чтобы удобно изменять свойство в пулбэке через keyPath можно вот так вот в экстеншен вынести составное свойтсво
extension AppState {

	var favoritePrimeState: FavoritePrimesState {
		get {
			FavoritePrimesState(
				favoritePrimes: favoritePrimes,
				activityFeed: activityFeed
			)
		}
		set {
			favoritePrimes = newValue.favoritePrimes
			activityFeed = newValue.activityFeed
		}
	}
}
