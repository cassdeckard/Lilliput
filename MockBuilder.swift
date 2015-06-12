import Foundation
import XCTest

class MockBuilder<A: Equatable, B: Equatable> {
    let testCase: XCTestCase

    init(testCase: XCTestCase) {
        self.testCase = testCase
    }

    func returning<ReturnType: DefaultConstructible>(returnType: ReturnType.Type) -> MockFunctionUsingDefaultConstructorForReturn<A, B, ReturnType> {
        return MockFunctionUsingDefaultConstructorForReturn<A, B, ReturnType>(testCase: self.testCase)
    }


    func returning<ReturnType>(returnType: ReturnType.Type) -> MockFunctionWithoutDefaultReturn<A, B, ReturnType> {
        return MockFunctionWithoutDefaultReturn<A, B, ReturnType>(testCase: self.testCase)
    }
}