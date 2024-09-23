//
//  AppEnvironment.swift
//  ComposableArch
//
//  Created by Pogosito on 23.09.2024.
//

import Counter
import FavoritePrimes
import ComposableArchitecture

typealias AppEnvironment = (
	fileClient: FileClient,
	nthPrimeEffect: (Int) -> Effect<Int?>
)
