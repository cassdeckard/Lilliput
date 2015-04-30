import Foundation
import XCTest

class MockFunc<Input, Output> {
    typealias MockedFunc = (Input) -> (Output)
    typealias Callback = (Input) -> (Output)

    var capturedArguments: [(Input)] = []
    var callback: Callback!

    func call(input: Input) -> (Output) {
        capturedArguments.append(input)
        return callback(input)
    }

    func when(callback: Callback) {
        self.callback = callback
    }

    var timesCalled: Int {
        get {
            return self.capturedArguments.count
        }
    }
}

class MockVoidFunc<Input> : MockFunc<Input, Void> {
    override func call(input: Input) -> () {
        capturedArguments.append(input)
    }
}

extension XCTestCase {
    func verifyAtLeastOnce<Input, Output>(mockFunc: MockFunc<Input, Output>,
        inFile filePath: String = __FILE__,
        atLine lineNumber: UInt = __LINE__) -> () {
            if (mockFunc.timesCalled < 1) {
                self.recordFailureWithDescription("Mocked function was not called at least once", inFile: filePath, atLine: lineNumber, expected: true)
            }
    }

    func when<Input, Output>(mockFunc: MockFunc<Input, Output>, callback: MockFunc<Input, Output>.Callback) -> () {
        mockFunc.when(callback)
    }

    func mock<Input, Output>(realFunc: (Input) -> (Output)) -> MockFunc<Input, Output> {
        return MockFunc<Input, Output>()
    }

    func mock<Input>(realFunc: (Input) -> ()) -> MockFunc<Input, Void> {
        return MockVoidFunc<Input>()
    }
}

prefix operator * {}

prefix func *<Input, Output>(mockFunc: MockFunc<Input, Output>) -> (MockFunc<Input, Output>.MockedFunc) {
    return mockFunc.call
}

prefix func *<Input>(mockFunc: MockFunc<Input, Void>) -> (MockVoidFunc<Input>.MockedFunc) {
    return (mockFunc as! MockVoidFunc<Input>).call
}
