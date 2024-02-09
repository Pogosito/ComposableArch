//
//  ContentView.swift
//  ComposableArch
//
//  Created by Pogosito on 08.02.2024.
//

import SwiftUI

struct ContentView: View {

	@ObservedObject var state: AppState

	var body: some View {
		NavigationStack {
			List {
				NavigationLink {
					CounterView(state: state)
				} label: {
					Text("Counter demo")
				}

				NavigationLink {
					Text("Dome")
				} label: {
					Text("Favorite promise")
				}
			}
		}
	}
}

#Preview {
	ContentView(state: .init())
}
