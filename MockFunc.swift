import Foundation
import XCTest

class MockFunc<Input, Output> {
    typealias MockedFunc = (Input) -> (Output)
    typealias Callback = (Input) -> (Output)

    var calls: [(Input)] = []
    var callback: Callback!

    func call(input: Input) -> (Output) {
        calls.append(input)
        return callback(input)
    }

    func when(callback: Callback) {
        self.callback = callback
    }
}

func when<Input, Output>(mockFunc : MockFunc<Input, Output>, callback: MockFunc<Input, Output>.Callback) -> () {
    mockFunc.when(callback)
}

prefix operator * {}
prefix func *<Input, Output>(mockFunc: MockFunc<Input, Output>) -> (MockFunc<Input, Output>.MockedFunc) {
    return mockFunc.call
}

extension XCTestCase {
    func verifyAtLeastOnce<Input, Output>(mockFunc: MockFunc<Input, Output>,
        inFile filePath: String = __FILE__,
        atLine lineNumber: UInt = __LINE__) -> () {
            if (mockFunc.calls.count < 1) {
                self.recordFailureWithDescription("Mocked function was not called at least once", inFile: filePath, atLine: lineNumber, expected: true)
            }
    }
}
