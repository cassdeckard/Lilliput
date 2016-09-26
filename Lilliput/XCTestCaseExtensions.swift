import Foundation
import XCTest

extension XCTestCase {

    func when<A: Equatable, B: Equatable>(_ argA: A, _ argB: B) -> Binding<A, B> {
        return Binding(testCase: self, argA, argB)
    }

    func when<A: Equatable>(_ argA: A) -> Binding<A, NoArgument> {
        return Binding(testCase: self, argA, NoArgument())
    }

    func verifyBoundArgumentsAreValid<A: Equatable, B: Equatable>(_ binding: Binding<A, B>,
        inFile filePath: String = #file,
        atLine lineNumber: UInt = #line) -> () {
            if !(binding.boundArgumentA.isValid() &&
                binding.boundArgumentB.isValid()) {
                    self.recordFailure(withDescription: "One or more bound arguments is not valid", inFile: filePath, atLine: lineNumber, expected: true)
            }
    }

    func verifyNever<A: Equatable, B: Equatable, ReturnType>(_ mockFunc: MockFunction<A, B, ReturnType>,
        inFile filePath: String = #file,
        atLine lineNumber: UInt = #line) -> () {
            if (mockFunc.invocationCount != 0) {
                self.recordFailure(withDescription: "Mocked function was called more than zero times", inFile: filePath, atLine: lineNumber, expected: true)
            }
    }

    func verifyAtLeastOnce<A: Equatable, B: Equatable, ReturnType>(_ mockFunc: MockFunction<A, B, ReturnType>,
        inFile filePath: String = #file,
        atLine lineNumber: UInt = #line) -> () {
            if (mockFunc.invocationCount < 1) {
                self.recordFailure(withDescription: "Mocked function was not called at least once", inFile: filePath, atLine: lineNumber, expected: true)
            }
    }
}
