//
//  ComposableArchApp.swift
//  ComposableArch
//
//  Created by Pogosito on 08.02.2024.
//

import SwiftUI

@main
struct ComposableArchApp: App {

	var body: some Scene {
		WindowGroup {
			ContentView(
				store: Store(
					initialValue: AppState(),
					// Не нравится вложенность использовали функцию with из их SDK,
					// чтобы красиво разбить вложенность (пока не стал использовать)
					reducer: logging(activivtyFeed(appReducer))
				)
			)
		}
	}
}
