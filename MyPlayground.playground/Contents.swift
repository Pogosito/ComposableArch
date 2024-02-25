import UIKit
import PlaygroundSupport
import SwiftUI

import ComposableArchitecture
import FavoritePrimes
import Counter

//PlaygroundPage.current.liveView = UIHostingController(
//	rootView: FavoritePrimesView(
//		store: Store<[Int], FavoritePrimesActions>(
//			initialValue: [3, 5],
//			reducer: favoritePrimesReducer
//		)
//	)
//)

PlaygroundPage.current.liveView = UIHostingController(
	rootView: CounterView(
		store: Store<CounterViewState, CounterViewActions>(
			initialValue: (0, []),
			reducer: counterViewReducer
		)
	)
)
