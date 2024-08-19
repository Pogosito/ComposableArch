import ComposableArchitecture
@testable import FavoritePrimes
import PlaygroundSupport
import SwiftUI

Current = .mock

PlaygroundPage.current.needsIndefiniteExecution = true
Current.fileClient.load = { _ in
	Effect.sync {
		try! JSONEncoder().encode(Array(1...10000000))
	}
}

PlaygroundPage.current.liveView = UIHostingController(
	rootView: NavigationView {
		FavoritePrimesView(
			store: Store<[Int], FavoritePrimesActions>(
				initialValue: [2, 3, 5, 7, 11],
				reducer: favoritePrimesReducer
			)
		)
	}
	.navigationViewStyle(.stack)
)
