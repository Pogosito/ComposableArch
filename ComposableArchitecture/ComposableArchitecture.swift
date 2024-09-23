//
//  ComposableArchitecture.swift
//  ComposableArchitecture
//
//  Created by Pogosito on 14.02.2024.
//

import SwiftUI
import Combine


public typealias Reducer<Value, Action, Environment> = (inout Value, Action, Environment) -> [Effect<Action>]

// Мы не хотим, чтобы наш слой модели был зависим от фреймворков, поэтому в модели мы не используем обертки Combine
// Но чтобы получить пользу от оберток Combine создаим вот такой дженерик класс
// который может получить на вход любую модель и дейтсвие, которое нужно осущетсвить над моделью
public final class Store<Value, Action>: ObservableObject {

    private let reducer: Reducer<Value, Action, Any>
	private var environment: Any?
	@Published public private(set) var value: Value
	private var viewCancellable: Cancellable?
	private var effectCancellables: Set<AnyCancellable> = []

	public init<Environment>(
		initialValue: Value,
		reducer: @escaping Reducer<Value, Action, Environment>,
		environment: Environment
	) {
		self.reducer = { value, action, environment in
			reducer(&value, action, environment as! Environment)
		}
		self.value = initialValue
		self.environment = environment
	}

	public func send(_ action: Action) {
		let effects = reducer(&value, action, environment)
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
			initialValue: toLocalValue(value),
			reducer: { localValue, localAction, _ in
				self.send(toGlobalAction(localAction))
				localValue = toLocalValue(self.value)
				return []
			},
			environment: self.environment
		)
		localStore.viewCancellable = $value.sink { [weak localStore] newValue in
			localStore?.value = toLocalValue(newValue)
		}
		return localStore
	}
}

// Наш reducer будет большим если все засовывать в один метод,
// поэтому сделаем вот такую функцию, чтобы можно
// было разбить функцию reduce на кусочки
public func combine<Value, Action, Environment>(
    _ reducers: Reducer<Value, Action, Environment>...
) -> Reducer<Value, Action, Environment> {
	return { value, action, environment in
		let effects: [Effect] = reducers.flatMap { $0(&value, action, environment) }
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
	GlobalAction,
    LocalEnvironment,
    GlobalEnvironment
>(
	_ reducer: @escaping Reducer<LocalValue, LocalAction, LocalEnvironment>,
	value: WritableKeyPath<GlobalValue, LocalValue>,
	action: WritableKeyPath<GlobalAction, LocalAction?>,
    environment: @escaping (GlobalEnvironment) -> LocalEnvironment
) -> Reducer<GlobalValue, GlobalAction, GlobalEnvironment> {
	return { globalValue, globalAction, globalEnvironment in
		guard let localAction = globalAction[keyPath: action] else { return [] }
		let localEffects = reducer(
			&globalValue[keyPath: value],
			localAction,
            environment(globalEnvironment)
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

public func logging<Value, Action, Environment>(
	_ reducer: @escaping Reducer<Value, Action, Environment>
) -> Reducer<Value, Action, Environment> {

	return { value, action, environment in
		let effects = reducer(&value, action, environment)
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
