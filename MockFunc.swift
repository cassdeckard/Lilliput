import Foundation

class MockFunc<Input, Output> {
    typealias MockedFunc = (Input) -> (Output)
    var calls: [(Input)] = []
    var result: (Output)!

    func call(input: Input) -> (Output) {
        calls.append(input)
        return result
    }
}