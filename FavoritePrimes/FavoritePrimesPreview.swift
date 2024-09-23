//
//  FavoritePrimesPreview.swift
//  ComposableArch
//
//  Created by Pogosito on 23.09.2024.
//

import SwiftUI
import ComposableArchitecture

struct FavoritePrimesPreview: PreviewProvider {

	static var previews: some View {
		var environment = FavoritePrimesEnvironment.mock
		environment.load = { _ in
			Effect.sync { try! JSONEncoder().encode(Array(1...14)) }
		}
		return NavigationView {
			FavoritePrimesView(
				store: Store<[Int], FavoritePrimesActions>(
					initialValue: [2, 3, 5, 7, 11],
					reducer: favoritePrimesReducer,
					environment: environment
				)
			)
		}
	}
}
