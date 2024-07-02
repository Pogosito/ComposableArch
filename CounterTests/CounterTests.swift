//
//  CounterTests.swift
//  CounterTests
//
//  Created by Pogosito on 14.02.2024.
//

import XCTest
@testable import Counter

final class CounterTests: XCTestCase {

	func testIncrButtonTapped() {
		var state = CounterViewState(
			alertNthPrime: nil,
			count: 2,
			favoritePrimes: [3, 5],
			isNthPrimeButtonDisabled: false,
			isAlertShown: false
		)

		let effects = counterViewReducer(&state, .counter(.incrTapped))

		XCTAssertEqual(
			state,
			CounterViewState(
				alertNthPrime: nil,
				count: 3,
				favoritePrimes: [3, 5],
				isNthPrimeButtonDisabled: false,
				isAlertShown: false
			)
		)
		XCTAssert(effects.isEmpty)
	}

	func testDecrButtonTapped() {
		var state = CounterViewState(
			alertNthPrime: nil,
			count: 2,
			favoritePrimes: [3, 5],
			isNthPrimeButtonDisabled: false,
			isAlertShown: false
		)

		let effects = counterViewReducer(&state, .counter(.decrTapped))

		XCTAssertEqual(
			state,
			CounterViewState(
				alertNthPrime: nil,
				count: 1,
				favoritePrimes: [3, 5],
				isNthPrimeButtonDisabled: false,
				isAlertShown: false
			)
		)
		XCTAssert(effects.isEmpty)
	}

	func testNthPrimeButtonHappyFlow() {
		var state = CounterViewState(
			alertNthPrime: nil,
			count: 2,
			favoritePrimes: [3, 5],
			isNthPrimeButtonDisabled: false,
			isAlertShown: false
		)

		var effects = counterViewReducer(
			&state,
			CounterViewAction.counter(.nthPrimeButtonTapped)
		)

		XCTAssertEqual(
			state,
			CounterViewState(
				alertNthPrime: nil,
				count: 2,
				favoritePrimes: [3, 5],
				isNthPrimeButtonDisabled: true
			)
		)

		XCTAssertEqual(effects.count, 1)

		effects = counterViewReducer(
			&state,
			CounterViewAction.counter(CounterAction.nthPrimeResponse(3))
		)

		XCTAssertEqual(
			state,
			CounterViewState(
				alertNthPrime: PrimeAlert(prime: 3),
				count: 2,
				favoritePrimes: [3, 5],
				isNthPrimeButtonDisabled: false,
				isAlertShown: true
			)
		)

		XCTAssert(effects.isEmpty)

		effects = counterViewReducer(
			&state,
			.counter(.alertDismissButtonTapped)
		)

		XCTAssertEqual(
			state,
			CounterViewState(
				alertNthPrime: nil,
				count: 2,
				favoritePrimes: [3, 5],
				isNthPrimeButtonDisabled: false
			)
		)

		XCTAssert(effects.isEmpty)
	}

	func testNthPrimeButtonLessHappyFlow() {
		var state = CounterViewState(
			alertNthPrime: nil,
			count: 2,
			favoritePrimes: [3, 5],
			isNthPrimeButtonDisabled: false,
			isAlertShown: false
		)

		var effects = counterViewReducer(
			&state,
			CounterViewAction.counter(.nthPrimeButtonTapped)
		)

		XCTAssertEqual(
			state,
			CounterViewState(
				alertNthPrime: nil,
				count: 2,
				favoritePrimes: [3, 5],
				isNthPrimeButtonDisabled: true
			)
		)

		XCTAssertEqual(effects.count, 1)

		effects = counterViewReducer(
			&state,
			CounterViewAction.counter(CounterAction.nthPrimeResponse(nil))
		)

		XCTAssertEqual(
			state,
			CounterViewState(
				alertNthPrime: nil,
				count: 2,
				favoritePrimes: [3, 5],
				isNthPrimeButtonDisabled: false,
				isAlertShown: true
			)
		)

		XCTAssert(effects.isEmpty)

		effects = counterViewReducer(
			&state,
			.counter(.alertDismissButtonTapped)
		)

		XCTAssertEqual(
			state,
			CounterViewState(
				alertNthPrime: nil,
				count: 2,
				favoritePrimes: [3, 5],
				isNthPrimeButtonDisabled: false
			)
		)

		XCTAssert(effects.isEmpty)
	}

	func testPrimeModal() {
		var state = CounterViewState(
			alertNthPrime: nil,
			count: 2,
			favoritePrimes: [3, 5],
			isNthPrimeButtonDisabled: false
		)

		var effects = counterViewReducer(&state, .primeModal(.saveFavoritePrimeTapped))

		XCTAssertEqual(
			state,
			CounterViewState(
				alertNthPrime: nil,
				count: 2,
				favoritePrimes: [3, 5, 2],
				isNthPrimeButtonDisabled: false
			)
		)

		XCTAssert(effects.isEmpty)

		effects = counterViewReducer(&state, .primeModal(.removeFavoritePrimeTapped))

		XCTAssertEqual(
			state,
			CounterViewState(
				alertNthPrime: nil,
				count: 2,
				favoritePrimes: [3, 5],
				isNthPrimeButtonDisabled: false
			)
		)
		XCTAssert(effects.isEmpty)
	}
}
