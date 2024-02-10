//
//  WolframAlphaResult.swift
//  ComposableArch
//
//  Created by Pogosito on 10.02.2024.
//

import Foundation

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
