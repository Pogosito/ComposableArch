//
//  AppState.swift
//  ComposableArch
//
//  Created by Pogosito on 08.02.2024.
//

import SwiftUI

final class AppState: ObservableObject {

	@Published var count = 0

	@Published var favoritePrimes: [Int] = []
}
