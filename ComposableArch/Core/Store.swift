//
//  Store.swift
//  ComposableArch
//
//  Created by Pogosito on 12.02.2024.
//

import SwiftUI

// Мы не хотим, чтобы наш слой модели был зависим от фреймворков, поэтому в модели мы не используем обертки Combine
// Но чтобы получить пользу от оберток Combine создаим вот такой дженерик класс
// который может получить на вход любую модель и дейтсвие, которое нужно осущетсвить над моделью
final class Store<Value, Action>: ObservableObject {

	private let reducer: (inout Value, Action) -> Void
	@Published private(set) var value: Value

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
