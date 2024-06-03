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

let appReducer = combine(
	pullback(counterViewReducer, value: \AppState.counterView, action: \AppAction.counterView),
	pullback(favoritePrimesReducer, value: \AppState.favoritePrimes, action: \AppAction.favoritePrimes)
)
