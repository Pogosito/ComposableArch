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

let appReducer: (inout AppState, AppAction) -> Void = combine(
	pullback(counterViewReducer, value: \.counterView, action: \.counterView),
	pullback(favoritePrimesReducer, value: \.favoritePrimes, action: \.favoritePrimes)
)
