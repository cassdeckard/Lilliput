import Foundation
import XCTest

extension XCTestCase {
    func mock<A: Equatable, B: Equatable>(a: A.Type, _ b: B.Type) -> MockBuilder<A, B> {
        return MockBuilder<A, B>(testCase: self)
    }

    func mock<A: Equatable>(a: A.Type) -> MockBuilder<A, NoArgument> {
        return MockBuilder<A, NoArgument>(testCase: self)
    }

    func when<A: Equatable, B: Equatable>(argA: A, _ argB: B) -> Binding<A, B> {
        return Binding(testCase: self, argA, argB)
    }

    func when<A: Equatable>(argA: A) -> Binding<A, NoArgument> {
        return Binding(testCase: self, argA, NoArgument())
    }

    func verifyBoundArgumentsAreValid<A: Equatable, B: Equatable>(binding: Binding<A, B>,
        inFile filePath: String = __FILE__,
        atLine lineNumber: UInt = __LINE__) -> () {
            if !(binding.boundArgumentA.isValid() &&
                binding.boundArgumentB.isValid()) {
                    self.recordFailureWithDescription("One or more bound arguments is not valid", inFile: filePath, atLine: lineNumber, expected: true)
            }
    }

    func verifyNever<A: Equatable, B: Equatable, ReturnType>(mockFunc: MockFunction<A, B, ReturnType>,
        inFile filePath: String = __FILE__,
        atLine lineNumber: UInt = __LINE__) -> () {
            if (mockFunc.invocationCount != 0) {
                self.recordFailureWithDescription("Mocked function was called more than zero times", inFile: filePath, atLine: lineNumber, expected: true)
            }
    }

    func verifyAtLeastOnce<A: Equatable, B: Equatable, ReturnType>(mockFunc: MockFunction<A, B, ReturnType>,
        inFile filePath: String = __FILE__,
        atLine lineNumber: UInt = __LINE__) -> () {
            if (mockFunc.invocationCount < 1) {
                self.recordFailureWithDescription("Mocked function was not called at least once", inFile: filePath, atLine: lineNumber, expected: true)
            }
    }
}
