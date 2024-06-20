import UIKit
import PlaygroundSupport
import SwiftUI

public struct Effect<A> {
	public let run: (@escaping (A) -> Void) -> Void

	public func map<B>(_ f: (A) -> B) -> Effect<B> {
		Effect<B> { callback in
			self.run() {
				
			}
			self.run { a in
				callback(f(a))
			}
		}
	}
}
