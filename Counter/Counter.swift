//
//  Counter.swift
//  Counter
//
//  Created by Pogosito on 15.02.2024.
//

import SwiftUI
import ComposableArchitecture
import PrimeModal
import Combine

public struct CounterViewState {
	public var alertNthPrime: PrimeAlert?
	public var count: Int
	public var favoritePrimes: [Int]
	public var isNthPrimeButtonDisabled: Bool
	public var isAlertShown: Bool

	var counter: CounterState {
		get { (self.alertNthPrime, self.count, self.isNthPrimeButtonDisabled, isAlertShown) }
		set { (self.alertNthPrime, self.count, self.isNthPrimeButtonDisabled, isAlertShown) = newValue }
	}

	var primeModal: PrimeModalState {
		get { (self.count, self.favoritePrimes) }
		set { (self.count, self.favoritePrimes) = newValue }
	}

	public init(
		alertNthPrime: PrimeAlert? = nil,
		count: Int,
		favoritePrimes: [Int],
		isNthPrimeButtonDisabled: Bool,
		isAlertShown: Bool = false
	) {
		self.alertNthPrime = alertNthPrime
		self.count = count
		self.favoritePrimes = favoritePrimes
		self.isNthPrimeButtonDisabled = isNthPrimeButtonDisabled
		self.isAlertShown = isAlertShown
	}
}

public typealias CounterState = (
	alertNthPrime: PrimeAlert?,
	count: Int,
	isNthPrimetButtonDisabled: Bool,
	isAlertShown: Bool
)

public enum CounterAction {
	case decrTapped
	case incrTapped
	case nthPrimeButtonTapped
	case nthPrimeResponse(Int?)
	case alertDismissButtonTapped
}

public func counterReducer(
	state: inout CounterState,
	action: CounterAction
) -> [Effect<CounterAction>] {
	switch action {
	case .decrTapped:
		state.count -= 1
		return []
	case .incrTapped:
		state.count += 1
		return []
	case .nthPrimeButtonTapped:
		state.isNthPrimetButtonDisabled = true
		return [
			nthPrime(state.count)
				.map { CounterAction.nthPrimeResponse($0) }
				.receive(on: DispatchQueue.main)
				.eraseToEffect()
		]
	case let .nthPrimeResponse(prime):
		state.alertNthPrime = prime.map(PrimeAlert.init(prime:))
		state.isNthPrimetButtonDisabled = false
		state.isAlertShown = true
		return []
	case .alertDismissButtonTapped:
		state.isAlertShown = false
		state.alertNthPrime = nil
		return []
	}
}

public enum CounterViewAction {
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

public let counterViewReducer = combine(
	pullback(counterReducer, value: \CounterViewState.counter, action: \CounterViewAction.counter),
	pullback(primeModalReducer, value: \.primeModal, action: \.primeModal)
)

public struct PrimeAlert: Identifiable {
	let prime: Int
	public var id: Int { self.prime }
}

public struct CounterView: View {

	@ObservedObject var store: Store<CounterViewState, CounterViewAction>

	@State private var isPrimeModalShown: Bool = false

	public init(
		store: Store<CounterViewState, CounterViewAction>
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

			Button(
				"What is the \(ordinal(store.value.count)) prime?",
				action: nthPrimeButtonAction
			)
			.disabled(self.store.value.isNthPrimeButtonDisabled)
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
			isPresented: .constant(store.value.isAlertShown),
			actions: {
				Button {
					store.send(.counter(.alertDismissButtonTapped))
				} label: {
					Text("Ok")
				}
			}
		) {
			Text(
				"The \(ordinal(store.value.count)) prime is \(self.store.value.alertNthPrime?.prime ?? 0)"
			)
		}
	}

	func nthPrimeButtonAction() {
		store.send(.counter(.nthPrimeButtonTapped))
	}
}

private extension CounterView {

	func ordinal(_ n: Int) -> String {
		let formatter = NumberFormatter()
		formatter.numberStyle = .ordinal
		return formatter.string(for: n) ?? ""
	}
}

func nthPrime(_ n: Int) -> Effect<Int?> {
	return wolframAlpha(query: "prime \(n)").map { result in
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
	}
	.eraseToEffect()
}

func wolframAlpha(
	query: String
) -> Effect<WolframAlphaResult?> {
	var components = URLComponents(string: "https://api.wolframalpha.com/v2/query")!
	components.queryItems = [
		URLQueryItem(name: "input", value: query),
		URLQueryItem(name: "format", value: "plaintext"),
		URLQueryItem(name: "output", value: "JSON"),
		URLQueryItem(name: "appid", value: "A5EJY6-KYRV8GQQT4")
	]

	return URLSession.shared
		.dataTaskPublisher(for: components.url!)
		.map { data, _ in data }
		.decode(type: WolframAlphaResult?.self, decoder: JSONDecoder())
		.replaceError(with: nil)
		.eraseToEffect()
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
