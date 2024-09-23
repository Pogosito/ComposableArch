//
//  FavoritePrimes.swift
//  FavoritePrimes
//
//  Created by Pogosito on 15.02.2024.
//

import SwiftUI
import ComposableArchitecture
import Combine

public enum FavoritePrimesActions: Equatable {
	case deleteFavoritePrimes(IndexSet)
	case loadedFavoritePrimes([Int])
	case saveButtonTapped
	case loadButtonTapped
}

public func favoritePrimesReducer(
	state: inout [Int],
	action: FavoritePrimesActions,
	environment: FavoritePrimesEnvironment
) -> [Effect<FavoritePrimesActions>] {
	switch action {
	case let .deleteFavoritePrimes(indexSet):
		for index in indexSet {
			state.remove(at: index)
		}
		return []
	case let .loadedFavoritePrimes(favoritePrimes):
		state = favoritePrimes
		return []
	case .saveButtonTapped:
		return [
			environment.save(
				"favorite-primes.json",
				try! JSONEncoder().encode(state)
			)
			.fireAndForget()
		]
	case .loadButtonTapped:
		return [
			environment.load("favorite-primes.json")
				.compactMap { $0 }
				.decode(type: [Int].self, decoder: JSONDecoder())
				.catch { error in Empty(completeImmediately: true) }
				.map(FavoritePrimesActions.loadedFavoritePrimes)
				.eraseToEffect()
		]
	}
}

public struct FileClient {
	var load: (String) -> Effect<Data?>
	var save: (String, Data) -> Effect<Never>
}

extension FileClient {
	public static let live = FileClient { fileName -> Effect<Data?> in
		.sync {
			let documentPath = NSSearchPathForDirectoriesInDomains(
				.documentDirectory,
				.userDomainMask,
				true
			)[0]
			let documentsUrl = URL(fileURLWithPath: documentPath)
			let favoritePrimesUrl = documentsUrl.appendingPathComponent(fileName)
			return try? Data(contentsOf: favoritePrimesUrl)
		}
	} save: { fileName, data in
		.fireAndForget {
			let documentPath = NSSearchPathForDirectoriesInDomains(
				.documentDirectory,
				.userDomainMask,
				true
			)[0]
			let documentsUrl = URL(fileURLWithPath: documentPath)
			let favoritePrimesUrl = documentsUrl.appendingPathComponent(fileName)
			try! data.write(to: favoritePrimesUrl)
		}
	}
}

public typealias FavoritePrimesEnvironment = FileClient

#if DEBUG
extension FileClient {

	static let mock = FileClient(
		load: { _ in
			Effect<Data?>.sync {
				try! JSONEncoder().encode([2, 31])
			}
		},
		save: { _, _ in .fireAndForget {} }
	)
}
#endif

extension Publisher where Output == Never, Failure == Never {

	func fireAndForget<A>() -> Effect<A> {
		self.map(absurd).eraseToEffect()
	}
}

func absurd<A>(_ never: Never) -> A {}

//
//private func saveEffect(favoritePrimes: [Int]) -> Effect<FavoritePrimesActions> {
//	.fireAndForget {
//		let data = try! JSONEncoder().encode(favoritePrimes)
//		let documentPath = NSSearchPathForDirectoriesInDomains(
//			.documentDirectory,
//			.userDomainMask,
//			true
//		)[0]
//		let documentsUrl = URL(fileURLWithPath: documentPath)
//		let favoritePrimesUrl = documentsUrl.appendingPathComponent("favorite-primes.json")
//		try! data.write(to: favoritePrimesUrl)
//	}
//}

//private func loadEffect() -> Effect<FavoritePrimesActions?> {
//	Effect<FavoritePrimesActions?>.sync {
//		let documentPath = NSSearchPathForDirectoriesInDomains(
//			.documentDirectory,
//			.userDomainMask,
//			true
//		)[0]
//		let documentsUrl = URL(fileURLWithPath: documentPath)
//		let favoritePrimesUrl = documentsUrl.appendingPathComponent("favorite-primes.json")
//		guard
//			let data = try? Data(contentsOf: favoritePrimesUrl),
//			let favoritePrimes = try? JSONDecoder().decode([Int].self, from: data)
//		else { return nil }
//		return .loadedFavoritePrimes(favoritePrimes)
//	}
//}

public struct FavoritePrimesView: View {

	@ObservedObject var store: Store<[Int], FavoritePrimesActions>

	public init(
		store: Store<[Int], FavoritePrimesActions>
	) {
		self.store = store
	}

	public var body: some View {
		List {
			ForEach(
				store.value,
				id: \.self
			) { prime in
				Text("\(prime)")
			}
			.onDelete(perform: { indexSet in
				store.send(
					.deleteFavoritePrimes(indexSet)
				)
			})
		}
		.navigationTitle(Text("Favorite Primes"))
		.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				HStack {
					Button("Save") {
						self.store.send(.saveButtonTapped)
					}

					Button("Load") {
						self.store.send(.loadButtonTapped)
					}
				}
			}
		}
	}
}
