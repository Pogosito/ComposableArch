//
//  Counter.swift
//  ComposableArch
//
//  Created by Pogosito on 11.02.2024.
//

import Foundation
import ComposableArchitecture
import Counter
import PrimeModal
import FavoritePrimes

let appReducer: Reducer<AppState, AppAction, AppEnvironment> = combine(
	pullback(
		counterViewReducer,
		value: \AppState.counterView,
		action: \AppAction.counterView,
		environment: { $0.nthPrimeEffect }
	),
	pullback(
		favoritePrimesReducer,
		value: \AppState.favoritePrimes,
		action: \AppAction.favoritePrimes,
		environment: { $0.fileClient }
	)
)
