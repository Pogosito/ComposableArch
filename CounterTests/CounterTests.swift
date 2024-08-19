//
//  CounterTests.swift
//  CounterTests
//
//  Created by Pogosito on 14.02.2024.
//

import XCTest
import Combine
import ComposableArchitecture
@testable import Counter

final class CounterTests: XCTestCase {

	override func setUp() {
		super.setUp()
		Current = .mock
	}

	func testIncrButtonTapped() {
		assert(
			initialValue: CounterViewState(count: 2),
			reducer: counterViewReducer,
			steps:
				Step(.send, .counter(.incrTapped)) { $0.count = 3 },
				Step(.send, .counter(.incrTapped)) { $0.count = 4 },
				Step(.send, .counter(.decrTapped)) { $0.count = 3 }
		)
	}

	func testDecrButtonTapped() {
		var state = CounterViewState(count: 2)
		var expected = state
		let effects = counterViewReducer(&state, .counter(.decrTapped))
 
		expected.count = 1
		XCTAssertEqual(state, expected)
		XCTAssert(effects.isEmpty)
	}

	func testNthPrimeButtonHappyFlow() {
		Current.nthPrime = { _ in .sync { 17 } }
		
		assert(
			initialValue: CounterViewState(
				alertNthPrime: nil,
				isNthPrimeButtonDisabled: false
			),
			reducer: counterViewReducer,
			steps:
				Step(.send, .counter(.nthPrimeButtonTapped)) {
					$0.isNthPrimeButtonDisabled = true
				},
			Step(.receive, .counter(.nthPrimeResponse(17))) {
				$0.alertNthPrime = PrimeAlert(prime: 17)
				$0.isNthPrimeButtonDisabled = false
				$0.isAlertShown = true
			},
			Step(.send, .counter(.alertDismissButtonTapped)) {
				$0.alertNthPrime = nil
				$0.isAlertShown = false
			}
		)
	}

	func testNthPrimeButtonUnhappyFlow() {
		Current.nthPrime = { _ in .sync { nil } }
		
		assert(
			initialValue: CounterViewState(
				alertNthPrime: nil,
				isNthPrimeButtonDisabled: false
			),
			reducer: counterViewReducer,
			steps:
				Step(.send, .counter(.nthPrimeButtonTapped)) {
					$0.isNthPrimeButtonDisabled = true
					$0.isAlertShown = false
				},
			Step(.receive, .counter(.nthPrimeResponse(nil))) {
				$0.isNthPrimeButtonDisabled = false
				$0.isAlertShown = true
			}
		)
	}

	func testPrimeModal() {
		assert(
			initialValue: CounterViewState(
				count: 2,
				favoritePrimes: [3, 5]
			),
			reducer: counterViewReducer,
			steps:
			Step(.send, .primeModal(.saveFavoritePrimeTapped)) { $0.favoritePrimes = [3, 5, 2] },
			Step(.send, .primeModal(.removeFavoritePrimeTapped)) { $0.favoritePrimes = [3, 5] }
		)
	}
}
