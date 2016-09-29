import Foundation
import XCTest

extension XCTestCase {
    func when<A>(_ argA: A) -> Binding<A, EqualsMatcher<A>> {
        return Binding(testCase: self, matcher: EqualsMatcher<A>(argA))
    }
}
