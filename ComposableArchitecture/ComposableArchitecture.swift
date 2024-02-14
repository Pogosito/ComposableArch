//
//  ComposableArchitecture.swift
//  ComposableArchitecture
//
//  Created by Pogosito on 14.02.2024.
//

import SwiftUI

// Мы не хотим, чтобы наш слой модели был зависим от фреймворков, поэтому в модели мы не используем обертки Combine
// Но чтобы получить пользу от оберток Combine создаим вот такой дженерик класс
// который может получить на вход любую модель и дейтсвие, которое нужно осущетсвить над моделью
public final class Store<Value, Action>: ObservableObject {

	private let reducer: (inout Value, Action) -> Void
	@Published public private(set) var value: Value

	public init(
		initialValue: Value,
		reducer: @escaping (inout Value, Action) -> Void
	) {
		self.value = initialValue
		self.reducer = reducer
	}

	public func send(_ action: Action) {
		reducer(&value, action)
	}
}

// Наш reducer будет большим если все засовывать в один метод,
// поэтому сделаем вот такую функцию, чтобы можно
// было разбить функцию reduce на кусочки
public func combine<Value, Action>(
	_ reducers: (inout Value, Action) -> Void...
) -> (inout Value, Action) -> Void {

	return { value, action in
		for reducer in reducers {
			reducer(&value, action)
		}
	}
}

// У нас теперь есть возможнось ограничивать у редюсера входящий тип и действие
// и использовать этот метод, чтобы передвать из глобовального сосотояния
// то что нужно (Хочу попробовать с keyPath поиграть)
public func pullback<
	LocalValue,
	GlobalValue,
	LocalAction,
	GloabalAction
>(
	_ reducer: @escaping (inout LocalValue, LocalAction) -> Void,
	value: WritableKeyPath<GlobalValue, LocalValue>,
	action: WritableKeyPath<GloabalAction, LocalAction?>
) -> (inout GlobalValue, GloabalAction) -> Void {
	return { globalValue, globalAction in
		guard let localAction = globalAction[keyPath: action] else { return }
		reducer(
			&globalValue[keyPath: value],
			localAction
		)
	}
}

public func logging<Value, Action>(
	_ reducer: @escaping (inout Value, Action) -> Void
) -> (inout Value, Action) -> Void {

	return { value, action in
		reducer(&value, action)
		print("Action: \(action)")
		print("Value:")
		dump(value)
		print("-----")
	}
}
