//
//  FavoritePrimes.swift
//  FavoritePrimes
//
//  Created by Pogosito on 15.02.2024.
//

import SwiftUI
import ComposableArchitecture

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
		return [loadEffect()]
	}
}

private func saveEffect(favoritePrimes: [Int]) -> Effect<FavoritePrimesActions> {
	Effect { _ in
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

private func loadEffect() -> Effect<FavoritePrimesActions> {
	Effect { callback in
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
		else { return }
		callback(.loadedFavoritePrimes(favoritePrimes))
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
