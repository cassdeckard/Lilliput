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