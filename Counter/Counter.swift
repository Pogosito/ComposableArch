//
//  Counter.swift
//  Counter
//
//  Created by Pogosito on 15.02.2024.
//

import SwiftUI
import ComposableArchitecture
import PrimeModal

public typealias CounterViewState = (count: Int, favoritePrimes: [Int])

public enum CounterAction {
	case decrTapped
	case incrTapped
}

public func counterReducer(
	state: inout Int,
	action: CounterAction
) {
	switch action {
	case .decrTapped: state -= 1
	case .incrTapped: state += 1
	}
}

public enum CounterViewActions {
	case counter(CounterAction)
	case primeModal(PrimeModalAction)

	var counter: CounterAction? {
		get {
			guard case let .counter(value) = self else { return nil }
			return value
		}
		set {
			guard case .counter = self,
				  let newValue = newValue else { return }
			self = .counter(newValue)
		}
	}

	var primeModal: PrimeModalAction? {
		get {
			guard case let .primeModal(value) = self else { return nil }
			return value
		}
		set {
			guard case .primeModal = self,
					let newValue = newValue else {
				return
			}
			self = .primeModal(newValue)
		}
	}
}

public var counterViewReducer: (inout CounterViewState, CounterViewActions) -> Void = combine(
	pullback(counterReducer, value: \.count, action: \.counter),
	pullback(primeModalReducer, value: \.self, action: \.primeModal)
)

public struct CounterView: View {

	@ObservedObject var store: Store<CounterViewState, CounterViewActions>

	@State private var isPrimeModalShown: Bool = false
	@State private var isAlertNthPrimeShowm: Bool = false
	@State private var alertNthPrime: Int?

	public init(
		store: Store<CounterViewState, CounterViewActions>
	) {
		self.store = store
	}

	public var body: some View {
		VStack {
			HStack {
				Button(action: {
					store.send(.counter(.decrTapped))
				}, label: {
					Text("-")
				})

				Text("\(store.value.count)")

				Button(action: {
					store.send(.counter(.incrTapped))
				}, label: {
					Text("+")
				})
			}

			Button(action: {
				isPrimeModalShown = true
			}, label: {
				Text("Is this prime?")
			})

			Button(action: {
				nthPrime(store.value.count) { prime in
					alertNthPrime = prime
					print("isAlertNthPrimeShowm:", isAlertNthPrimeShowm)
					isAlertNthPrimeShowm = true
				}
			}, label: {
				Text("What is the \(ordinal(store.value.count)) prime?")
			})
		}
		.font(.title)
		.navigationTitle("Counter demo")
		.navigationBarTitleDisplayMode(.large)
		.sheet(
			isPresented: $isPrimeModalShown,
			content: {
				IsPrimeModelView(
					store: store
						.view(
							value: { ($0.count, $0.favoritePrimes) },
							action: { .primeModal($0) }
						)
				)
			}
		)
		.alert(
			"Warning",
			isPresented: $isAlertNthPrimeShowm,
			actions: {
				Button {
					print(isAlertNthPrimeShowm)
				} label: {
					Text("Ok")
				}
			}
		) {
			Text(
				"The \(ordinal(store.value.count)) prime is \(alertNthPrime ?? 0)"
			)
		}
	}
}

private extension CounterView {

	func ordinal(_ n: Int) -> String {
		let formatter = NumberFormatter()
		formatter.numberStyle = .ordinal
		return formatter.string(for: n) ?? ""
	}
}

func nthPrime(_ n: Int, callback: @escaping (Int?) -> Void) -> Void {
	wolframAlpha(query: "prime \(n)") { result in
		callback(
			result
				.flatMap {
					$0.queryresult
						.pods
						.first(where: { $0.primary == .some(true)})?
						.subpods
						.first?
						.plaintext
			}
			.flatMap(Int.init)
		)
	}
}

func wolframAlpha(
	query: String,
	callback: @escaping (WolframAlphaResult?) -> Void
) -> Void {
	var components = URLComponents(string: "https://api.wolframalpha.com/v2/query")!
	components.queryItems = [
		URLQueryItem(name: "input", value: query),
		URLQueryItem(name: "format", value: "plaintext"),
		URLQueryItem(name: "output", value: "JSON"),
		URLQueryItem(name: "appid", value: "A5EJY6-KYRV8GQQT4")
	]

	URLSession.shared.dataTask(
		with: components.url(relativeTo: nil)!
	) { data, response, error in
		callback(
			data.flatMap { try? JSONDecoder().decode(WolframAlphaResult.self, from: $0 )}
		)
	}.resume()
}

struct WolframAlphaResult: Decodable {

	let queryresult: QueryResult

	struct QueryResult: Decodable {

		let pods: [Pod]

		struct Pod: Decodable {

			let primary: Bool?

			let subpods: [SubPod]

			struct SubPod: Decodable {
				let plaintext: String
			}
		}
	}
}
