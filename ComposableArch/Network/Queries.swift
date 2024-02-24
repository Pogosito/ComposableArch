//
//  Queries.swift
//  ComposableArch
//
//  Created by Pogosito on 10.02.2024.
//

import Foundation

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
