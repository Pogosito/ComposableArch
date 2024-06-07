//
//  ComposableArchitecture.swift
//  ComposableArchitecture
//
//  Created by Pogosito on 14.02.2024.
//

import SwiftUI
import Combine

public struct Effect<Output>: Publisher {

	public typealias Failure = Never

	let publisher: AnyPublisher<Output, Failure>

	public func receive<S>(
		subscriber: S
	) where S: Subscriber, Never == S.Failure, Output == S.Input {
		publisher.receive(subscriber: subscriber)
	}
}

extension Publisher where Failure == Never {

	public func eraseToEffect() -> Effect<Output> {
		Effect(publisher: self.eraseToAnyPublisher())
	}
}

public typealias Reducer<Value, Action> = (inout Value, Action) -> [Effect<Action>]

// Мы не хотим, чтобы наш слой модели был зависим от фреймворков, поэтому в модели мы не используем обертки Combine
// Но чтобы получить пользу от оберток Combine создаим вот такой дженерик класс
// который может получить на вход любую модель и дейтсвие, которое нужно осущетсвить над моделью
public final class Store<Value, Action>: ObservableObject {

	private let reducer: Reducer<Value, Action>
	@Published public private(set) var value: Value
	private var viewCancellable: Cancellable?
	private var effectCancellables: Set<AnyCancellable> = []

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
			var effectCancellable: AnyCancellable?
			var didComplete = false
			effectCancellable = effect.sink(
				receiveCompletion: { [weak self] _ in
					didComplete = true
					guard let effectCancellable else { return }
					self?.effectCancellables.remove(effectCancellable)
				},
				receiveValue: self.send
			)
			guard let effectCancellable, didComplete else { return }
			effectCancellables.insert(effectCancellable)
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
		localStore.viewCancellable = $value.sink { [weak localStore] newValue in
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
			localEffect.map { localAction -> GlobalAction in
				var globalAction = globalAction
				globalAction[keyPath: action] = localAction
				return globalAction
			}.eraseToEffect()
		}
	}
}

public func logging<Value, Action>(
	_ reducer: @escaping Reducer<Value, Action>
) -> Reducer<Value, Action> {

	return { value, action in
		let effects = reducer(&value, action)
		let newValue = value
		return [
			.fireAndForget {
				print("Action: \(action)")
				print("Value:")
				dump(newValue)
				print("-----")
			}
		] + effects
	}
}

extension Effect {

	public static func fireAndForget(work: @escaping () -> Void) -> Effect {
		return Deferred { () -> Empty<Output, Never> in
			work()
			return Empty(completeImmediately: true)
		}.eraseToEffect()
	}
}
