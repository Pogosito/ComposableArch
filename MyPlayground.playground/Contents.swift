import UIKit
import PlaygroundSupport
import SwiftUI

import ComposableArchitecture
import FavoritePrimes
import Counter

//PlaygroundPage.current.liveView = UIHostingController(
//	rootView: NavigationStack {
//		FavoritePrimesView(
//			store: Store<[Int], FavoritePrimesActions>(
//				initialValue: [3, 5],
//				reducer: favoritePrimesReducer
//			)
//		)
//	}
//)

let host = UIHostingController(
	rootView: CounterView(
		store: Store<CounterViewState, CounterViewAction>(
			initialValue: .init(
				count: 0,
				favoritePrimes: [1, 2, 3],
				isNthPrimeButtonDisabled: false
			),
			reducer: counterViewReducer
		)
	)
	.frame(width: 300, height: 700)
)

host.preferredContentSize = CGSize(width: 600, height: 600)
PlaygroundPage.current.liveView = host

//PlaygroundPage.current.liveView = UIHostingController(
//	rootView: CounterView(
//		store: Store<CounterViewState, CounterViewActions>(
//			initialValue: (0, []),
//			reducer: counterViewReducer
//		)
//	)
//)

//var aaa = KeyPath<SomeClass, Int>.Type

func pullback<LocalValue, GlobalValue, Action>(
	reduce: @escaping (inout LocalValue, Action) -> Void,
	value: WritableKeyPath<GlobalValue, LocalValue>
) -> (inout GlobalValue, Action) -> Void {
	return { globalValue, action in
		reduce(&globalValue[keyPath: value], action)
	}
}

class Pogos {
	var name: String = "Pogos"
}

var pogos = Pogos()


enum SomeAction {
	case changeName
	case addSymbol
}

func reduceName(string: inout String, action: SomeAction) {
	switch action {
	case .changeName: string = "Angelina + P"
	case .addSymbol: string = "Pogos + A"
	}
}

var aa = pullback(reduce: reduceName, value: \Pogos.name)

aa(&pogos, .addSymbol)

print(pogos.name)

func pullback<LocalValue, GlobalValue, LocalAction, GlobalAction>(
	reduce: @escaping (inout LocalValue, LocalAction) -> Void,
	value: WritableKeyPath<GlobalValue, LocalValue>,
	action: WritableKeyPath<GlobalAction, LocalAction?>
) -> (inout GlobalValue, GlobalAction) -> Void {
	return { globalValue, globalAction in
		guard let globalAction = globalAction[keyPath: action] else { return }
		reduce(&globalValue[keyPath: value], globalAction)
	}
}

func compute(_ x: Int) -> Int {
	return x * x + 1
}

// Side effect - это работа, которая выполняется "скрыто" от клиента
// Скрыта в том смысле, что он не имеет к результату этой работы доступа, например тут print выолняется в теле функции, мы знаем что там есть принт только посмотрев не получить факт того что произошел принт у нас нет
func computeWithEffetct(_ x: Int) -> Int {
	let computation = x * x + 1
	print("Computed: \(computation)")
	return computation
}

//func filterActions<Value, Action>(
//	_ predicate: @escaping (Action) -> Bool
//) -> (@escaping (inout Value, Action) -> Void) -> (inout Value, Action) -> Void {
//
//	return { reducer in
//		return { value, action in
//			if predicate(action) {
//				reducer(&value, action)
//			}
//		}
//	}
//}

//struct UndoState<Value> {
//
//	var value: Value
//	var history: [Value]
//	var undone: [Value]
//	var canUndo: Bool { !history.isEmpty }
//	var canRedo: Bool { !undone.isEmpty }
//}
//
//enum UndoAction<Action> {
//	case action(Action)
//	case undo
//	case redo
//}
//
//func undo<Value, Action>(
//  _ reducer: @escaping (inout Value, Action) -> Void,
//  limit: Int
//) -> (inout UndoState<Value>, UndoAction<Action>) -> Void {
//	return { undoState, undoAction in
//		switch undoAction {
//		case let .action(action):
//			var currentValue = undoState.value
//			reducer(&currentValue, action)
//			undoState.history.append(currentValue)
//			if undoState.history.count > limit {
//				undoState.history.removeFirst()
//			}
//		case .undo:
//			guard undoState.canUndo else { return }
//			undoState.undone.append(undoState.value)
//			undoState.value = undoState.history.removeLast()
//		case .redo:
//			guard undoState.canRedo else { return }
//			undoState.history.append(undoState.value)
//			undoState.value = undoState.undone.removeFirst()
//		}
//	}
//}
//public func pullback<
//	LocalValue,
//	GlobalValue,
//	LocalAction,
//	GlobalAction
//>(
//	_ reducer: @escaping Reducer<LocalValue, LocalAction>,
//	value: WritableKeyPath<GlobalValue, LocalValue>,
//	action: WritableKeyPath<GlobalAction, LocalAction?>
//) -> Reducer<GlobalValue, GlobalAction> {
//	return { globalValue, globalAction in
//		guard let localAction = globalAction[keyPath: action] else { return [] }
//		let localEffects = reducer(
//			&globalValue[keyPath: value],
//			localAction
//		)
//		return localEffects.map { localEffect in
//			Effect { callback in
//				localEffect.run { localAction in
//					var globalAction = globalAction
//					globalAction[keyPath: action] = localAction
//					callback(globalAction)
//				}
//			}
//		}
//	}
//}


