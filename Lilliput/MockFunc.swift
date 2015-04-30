import Foundation
import XCTest

protocol MockFunc {
    typealias Input
    typealias Output
    typealias MockedFunc
    typealias Callback

    var capturedArguments: [(Input)] { get set }
    var callback: Callback! { get set }
    var timesCalled: Int { get }

    func call(input: Input) -> (Output)
    func call<Input1, Input2>(input1: Input1, _ input2: Input2) -> Output

    func when(callback: Callback)
}

class _MockFunc<Input, Output> : MockFunc {
    typealias MockedFunc = (Input) -> (Output)
    typealias Callback = (Input) -> (Output)

    var capturedArguments: [(Input)] = []
    var callback: Callback!

    func call(input: Input) -> (Output) {
        capturedArguments.append(input)
        return callback(input)
    }

    func call<Input1, Input2>(input1: Input1, _ input2: Input2) -> Output {
        let input = (input1, input2) as! Input
        return self.call(input)
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

class _MockVoidFunc<Input> : _MockFunc<Input, Void> {
    override func call(input: Input) -> () {
        capturedArguments.append(input)
        if let callback = self.callback {
            callback(input)
        }
    }
}

extension XCTestCase {
    func verifyAtLeastOnce<Input, Output>(mockFunc: _MockFunc<Input, Output>,
        inFile filePath: String = __FILE__,
        atLine lineNumber: UInt = __LINE__) -> () {
            if (mockFunc.timesCalled < 1) {
                self.recordFailureWithDescription("Mocked function was not called at least once", inFile: filePath, atLine: lineNumber, expected: true)
            }
    }

    func when<Input, Output>(mockFunc: _MockFunc<Input, Output>, callback: _MockFunc<Input, Output>.Callback) -> () {
        mockFunc.when(callback)
    }

    func mock<Input, Output>(realFunc: (Input) -> (Output)) -> _MockFunc<Input, Output> {
        return _MockFunc<Input, Output>()
    }

    func mock<Input>(realFunc: (Input) -> ()) -> _MockFunc<Input, Void> {
        return _MockVoidFunc<Input>()
    }
}

prefix operator * {}

prefix func *<Input, Output>(mockFunc: _MockFunc<Input, Output>) -> (_MockFunc<Input, Output>.MockedFunc) {
    return mockFunc.call
}
prefix func *<Input1, Input2, Output>(mockFunc: _MockFunc<(Input1, Input2), Output>) -> ((Input1, Input2) -> (Output)) {
    return mockFunc.call
}

prefix func *<Input>(mockFunc: _MockFunc<Input, Void>) -> (_MockVoidFunc<Input>.MockedFunc) {
    return (mockFunc as! _MockVoidFunc<Input>).call
}
