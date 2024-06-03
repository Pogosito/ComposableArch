//
//  ComposableArchitecture.swift
//  ComposableArchitecture
//
//  Created by Pogosito on 14.02.2024.
//

import SwiftUI
import Combine

public struct Effect<A> {

	public let run: (@escaping (A) -> Void) -> Void

	public init(run: @escaping (@escaping (A) -> Void) -> Void) {
		self.run = run
	}

	public func map<B>(_ f: @escaping (A) -> B) -> Effect<B> {
		Effect<B> { callback in
			self.run { a in
				callback(f(a))
			}
		}
	}
}

public typealias Reducer<Value, Action> = (inout Value, Action) -> [Effect<Action>]

// Мы не хотим, чтобы наш слой модели был зависим от фреймворков, поэтому в модели мы не используем обертки Combine
// Но чтобы получить пользу от оберток Combine создаим вот такой дженерик класс
// который может получить на вход любую модель и дейтсвие, которое нужно осущетсвить над моделью
public final class Store<Value, Action>: ObservableObject {

	private let reducer: Reducer<Value, Action>
	@Published public private(set) var value: Value
	private var cancellable: Cancellable?

	public init(
		initialValue: Value,
		reducer: @escaping Reducer<Value, Action>
	) {
		self.value = initialValue
		self.reducer = reducer
	}

	public func send(_ action: Action) {
		let effects = reducer(&value, action)
		effects.forEach { effect in
			effect.run(self.send)
		}
	}

	public func view<LocalValue, LocalAction>(
		value toLocalValue: @escaping (Value) -> LocalValue,
		action toGlobalAction: @escaping (LocalAction) -> Action
	) -> Store<LocalValue, LocalAction> {
		let localStore = Store<LocalValue, LocalAction>(
			initialValue: toLocalValue(value)
		) { localValue, localAction in
			self.send(toGlobalAction(localAction))
			localValue = toLocalValue(self.value)
			return []
		}
		localStore.cancellable = $value.sink { [weak localStore] newValue in
			localStore?.value = toLocalValue(newValue)
		}
		return localStore
	}
}

// Наш reducer будет большим если все засовывать в один метод,
// поэтому сделаем вот такую функцию, чтобы можно
// было разбить функцию reduce на кусочки
public func combine<Value, Action>(
	_ reducers: Reducer<Value, Action>...
) -> Reducer<Value, Action> {
	return { value, action in
		let effects: [Effect] = reducers.flatMap { $0(&value, action) }
		return effects
	}
}

// У нас теперь есть возможнось ограничивать у редюсера входящий тип и действие
// и использовать этот метод, чтобы передвать из глобовального сосотояния
// то что нужно (Хочу попробовать с keyPath поиграть)
public func pullback<
	LocalValue,
	GlobalValue,
	LocalAction,
	GlobalAction
>(
	_ reducer: @escaping Reducer<LocalValue, LocalAction>,
	value: WritableKeyPath<GlobalValue, LocalValue>,
	action: WritableKeyPath<GlobalAction, LocalAction?>
) -> Reducer<GlobalValue, GlobalAction> {
	return { globalValue, globalAction in
		guard let localAction = globalAction[keyPath: action] else { return [] }
		let localEffects = reducer(
			&globalValue[keyPath: value],
			localAction
		)

		return localEffects.map { localEffect in
			Effect { callback in
				localEffect.run { localAcion in
					var globalAction = globalAction
					globalAction[keyPath: action] = localAcion
					callback(globalAction)
				}
			}
		}
	}
}
 
public func logging<Value, Action>(
	_ reducer: @escaping Reducer<Value, Action>
) -> Reducer<Value, Action> {

	return { value, action in
		let effects = reducer(&value, action)
		let newValue = value
		return [Effect { _ in
			print("Action: \(action)")
			print("Value:")
			dump(newValue)
			print("-----")
		}] + effects
	}
}
