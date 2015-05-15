import Foundation
import XCTest

protocol DefaultConstructable {
    init()
}

extension String: DefaultConstructable {}

class MockFunction<T: Hashable, ReturnType: DefaultConstructable> {
    typealias Signature = (T) -> ReturnType
    typealias TBinding = Binding<T>

    var bindings: [TBinding : ReturnType] = [:]
    var invocationCount = 0

    init(binding: Binding<T>, returnValue: ReturnType) {
        bindings[binding] = returnValue
    }

    func unbox() -> Signature {
        return {
            (arg: T) in
            self.invocationCount++
            for (binding, returnValue) in self.bindings {
                if arg == binding.boundArgument {
                    return returnValue
                }
            }
            return ReturnType()
        }
    }
}

class Binding<T where T: Hashable, T: Equatable> {
    let boundArgument: T

    init(_ arg: T) {
        boundArgument = arg
    }

    func then<ReturnType>(returnValue: ReturnType) -> MockFunction<T, ReturnType> {
        return MockFunction<T, ReturnType>(binding: self, returnValue: returnValue)
    }
}

extension Binding: Hashable {
    var hashValue: Int {
        get {
            return boundArgument.hashValue
        }
    }
}

func ==<T where T: Hashable, T: Equatable>(lhs: Binding<T>, rhs: Binding<T>) -> Bool {
    return lhs.boundArgument == rhs.boundArgument
}
extension Binding: Equatable {}

func when<T: Hashable>(arg: T) -> Binding<T> {
    return Binding(arg)
}

extension XCTestCase {
    func verifyAtLeastOnce<T: Hashable, ReturnType: DefaultConstructable>(mockFunc: MockFunction<T, ReturnType>,
        inFile filePath: String = __FILE__,
        atLine lineNumber: UInt = __LINE__) -> () {
            if (mockFunc.invocationCount < 1) {
                self.recordFailureWithDescription("Mocked function was not called at least once", inFile: filePath, atLine: lineNumber, expected: true)
            }
    }
}
