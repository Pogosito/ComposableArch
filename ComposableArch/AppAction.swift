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

	case counter(CounterAction)
	case primeModal(PrimeModalAction)
	case favoritePrimes(FavoritePrimesActions)

	// Таким образом мы получаем доступ к ассоциативным значениям enum
	// через точку
	var counter: CounterAction? {
		get {
			guard case let .counter(value) = self else { return nil }
			return value
		}
		set {
			guard case .counter = self,
				  let newValue = newValue else { return }
			self = .counter(newValue)
		}
	}

	var primeModal: PrimeModalAction? {
		get {
			guard case let .primeModal(value) = self else { return nil }
			return value
		}
		set {
			guard case .primeModal = self,
					let newValue = newValue else {
				return
			}
			self = .primeModal(newValue)
		}
	}

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
}
