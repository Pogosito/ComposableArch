//
//  ComposableArchitecture.swift
//  ComposableArchitecture
//
//  Created by Pogosito on 14.02.2024.
//

import SwiftUI
import Combine

// Мы не хотим, чтобы наш слой модели был зависим от фреймворков, поэтому в модели мы не используем обертки Combine
// Но чтобы получить пользу от оберток Combine создаим вот такой дженерик класс
// который может получить на вход любую модель и дейтсвие, которое нужно осущетсвить над моделью
public final class Store<Value, Action>: ObservableObject {

	private let reducer: (inout Value, Action) -> Void
	@Published public private(set) var value: Value
	private var cancellable: Cancellable?

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

	public func view<LocalValue, LocalAction>(
		value toLocalValue: @escaping (Value) -> LocalValue,
		action toGlobalAction: @escaping (LocalAction) -> Action
	) -> Store<LocalValue, LocalAction> {
		let localStore = Store<LocalValue, LocalAction>(
			initialValue: toLocalValue(value)
		) { localValue, localAction in
			self.send(toGlobalAction(localAction))
			localValue = toLocalValue(self.value)
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
	GlobalAction
>(
	_ reducer: @escaping (inout LocalValue, LocalAction) -> Void,
	value: WritableKeyPath<GlobalValue, LocalValue>,
	action: WritableKeyPath<GlobalAction, LocalAction?>
) -> (inout GlobalValue, GlobalAction) -> Void {
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

func filterActions<Value, Action>(
	_ predicate: @escaping (Action) -> Bool
) -> (@escaping (inout Value, Action) -> Void) -> (inout Value, Action) -> Void {

	return { reducer in
		return { value, action in
			if predicate(action) {
				reducer(&value, action)
			}
		}
	}
}

struct UndoState<Value> {

	var value: Value
	var history: [Value]
	var undone: [Value]
	var canUndo: Bool { !history.isEmpty }
	var canRedo: Bool { !undone.isEmpty }
}

enum UndoAction<Action> {
	case action(Action)
	case undo
	case redo
}

func undo<Value, Action>(
  _ reducer: @escaping (inout Value, Action) -> Void,
  limit: Int
) -> (inout UndoState<Value>, UndoAction<Action>) -> Void {
	return { undoState, undoAction in
		switch undoAction {
		case let .action(action):
			var currentValue = undoState.value
			reducer(&currentValue, action)
			undoState.history.append(currentValue)
			if undoState.history.count > limit {
				undoState.history.removeFirst()
			}
		case .undo:
			guard undoState.canUndo else { return }
			undoState.undone.append(undoState.value)
			undoState.value = undoState.history.removeLast()
		case .redo:
			guard undoState.canRedo else { return }
			undoState.history.append(undoState.value)
			undoState.value = undoState.undone.removeFirst()
		}
	}
}
