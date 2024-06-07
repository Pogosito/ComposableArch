//
//  FavoritePrimes.swift
//  FavoritePrimes
//
//  Created by Pogosito on 15.02.2024.
//

import SwiftUI
import ComposableArchitecture
import Combine

public enum FavoritePrimesActions {
	case deleteFavoritePrimes(IndexSet)
	case loadedFavoritePrimes([Int])
	case saveButtonTapped
	case loadButtonTapped
}

public func favoritePrimesReducer(
	state: inout [Int],
	action: FavoritePrimesActions
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
		return [saveEffect(favoritePrimes: state)]
	case .loadButtonTapped:
		return [
			loadEffect()
				.compactMap { $0 }
				.eraseToEffect()
		]
	}
}

extension Effect {

	static func sync(work: @escaping () -> Output) -> Effect {
		return Deferred {
			Just(work())
		}.eraseToEffect()
	}
}

private func saveEffect(favoritePrimes: [Int]) -> Effect<FavoritePrimesActions> {
	.fireAndForget {
		let data = try! JSONEncoder().encode(favoritePrimes)
		let documentPath = NSSearchPathForDirectoriesInDomains(
			.documentDirectory,
			.userDomainMask,
			true
		)[0]
		let documentsUrl = URL(fileURLWithPath: documentPath)
		let favoritePrimesUrl = documentsUrl.appendingPathComponent("favorite-primes.json")
		try! data.write(to: favoritePrimesUrl)
	}
}

private func loadEffect() -> Effect<FavoritePrimesActions?> {
	Effect<FavoritePrimesActions?>.sync {
		let documentPath = NSSearchPathForDirectoriesInDomains(
			.documentDirectory,
			.userDomainMask,
			true
		)[0]
		let documentsUrl = URL(fileURLWithPath: documentPath)
		let favoritePrimesUrl = documentsUrl.appendingPathComponent("favorite-primes.json")
		guard
			let data = try? Data(contentsOf: favoritePrimesUrl),
			let favoritePrimes = try? JSONDecoder().decode([Int].self, from: data)
		else { return nil }
		return .loadedFavoritePrimes(favoritePrimes)
	}
}

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
