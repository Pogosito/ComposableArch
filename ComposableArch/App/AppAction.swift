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
import Counter
import PrimeModal
import FavoritePrimes
import ComposableArchitecture

enum AppAction {

	case counterView(CounterViewAction)
	case favoritePrimes(FavoritePrimesActions)

	// Таким образом мы получаем доступ к ассоциативным значениям enum
	// через точку
	var favoritePrimes: FavoritePrimesActions? {
		get {
			guard case let .favoritePrimes(value) = self else {
				return nil
			}
			return value
		}
		set {
			guard case .favoritePrimes = self,
					let newValue = newValue else {
				return
			}
			self = .favoritePrimes(newValue)
		}
	}

	var counterView: CounterViewAction? {
		get {
			guard case let .counterView(value) = self else {
				return nil
			}
			return value
		}
		set {
			guard case .counterView = self,
					let newValue = newValue else {
				return
			}
			self = .counterView(newValue)
		}
	}
}
