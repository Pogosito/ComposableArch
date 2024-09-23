//
//  CounterPreview.swift
//  ComposableArch
//
//  Created by Pogosito on 23.09.2024.
//

import SwiftUI
import ComposableArchitecture

struct CounterPreview: PreviewProvider {

	static var previews: some View {
		var environment: CounterEnvironment = { _ in .sync {
			7236893748932
		}}
		return NavigationView {
			CounterView(
				store: Store<
					CounterViewState,
					CounterViewAction
				>(
					initialValue: CounterViewState(
						alertNthPrime: nil,
						count: 0,
						favoritePrimes: [],
						isNthPrimeButtonDisabled: false,
						isAlertShown: false
					),
					reducer: logging(counterViewReducer),
					environment: environment
				)
			)
		}
	}
}
