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
}

// Мы не хотим, чтобы наш слой модели был зависим от фреймворков, поэтому в модели мы не используем обертки Combine
// Но чтобы получить пользу от оберток Combine создаим вот такой дженерик класс
// который может получить на вход любую модел и дейтсвие которое нужно осущетсвиить на моделью
final class Store<Value, Action>: ObservableObject {

	private let reducer: (inout Value, Action) -> Void
	@Published var value: Value

	init(
		initialValue: Value,
		reducer: @escaping (inout Value, Action) -> Void
	) {
		self.value = initialValue
		self.reducer = reducer
	}

	func send(_ action: Action) {
		reducer(&value, action)
	}
}
