import Foundation
import XCTest

extension XCTestCase {
    func when<A>(_ argA: A) -> Binding<A> {
        return Binding(testCase: self, argA)
    }
}
