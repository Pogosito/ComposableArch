//
//  Effects.swift
//  ComposableArchitecture
//
//  Created by Pogosito on 04.06.2024.
//

import Combine

public struct Effect<Output>: Publisher {

	public typealias Failure = Never

	let publisher: AnyPublisher<Output, Failure>

	public func receive<S>(
		subscriber: S
	) where S: Subscriber, Never == S.Failure, Output == S.Input {
		publisher.receive(subscriber: subscriber)
	}
}

extension Publisher where Failure == Never {

	public func eraseToEffect() -> Effect<Output> {
		Effect(publisher: self.eraseToAnyPublisher())
	}
}

extension Effect {

	public static func sync(work: @escaping () -> Output) -> Effect {
		return Deferred {
			Just(work())
		}.eraseToEffect()
	}
}

//extension Effect where A == (Data?, URLResponse?, Error?) {
//
//	public func decode<M: Decodable>(as type: M.Type) -> Effect<M?> {
//		return self.map { data, _, _ in
//			data
//				.flatMap { try? JSONDecoder().decode(type.self, from: $0) }
//		}
//	}
//}
//
//extension Effect {
//
//	public func recive(on queue: DispatchQueue) -> Effect {
//		return Effect { callback in
//			self.run { a in
//				queue.async {
//					callback(a)
//				}
//			}
//		}
//	}
//}
//
//public func dataTask(url: URL) -> Effect<(Data?, URLResponse?, Error?)> {
//	Effect { callback in
//		URLSession.shared.dataTask(
//			with: url
//		) { data, response, error in
//			callback((data, response, error))
//		}.resume()
//	}
//}
