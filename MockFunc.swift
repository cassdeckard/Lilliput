import Foundation

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