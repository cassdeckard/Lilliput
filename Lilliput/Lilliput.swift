import Foundation
import XCTest

protocol DefaultConstructable {
    init()
}

extension String: DefaultConstructable {}

class _MockFunction<T: Hashable, ReturnType> {
    typealias Signature = (T) -> ReturnType
    typealias TBinding = Binding<T>
    typealias Bindings = [TBinding: ReturnType]

    var bindings: Bindings

    init(bindings: Bindings) {
        self.bindings = bindings
    }
}

class MockFunctionWithBoundDefaultReturn<T: Hashable, ReturnType>: _MockFunction<T, ReturnType> {
    var invocationCount = 0
    let defaultReturn: ReturnType

    init(bindings: Bindings, defaultReturn: ReturnType) {
        self.defaultReturn = defaultReturn
        super.init(bindings: bindings)
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
            return self.defaultReturn
        }
    }
}

class MockFunction<T: Hashable, ReturnType: DefaultConstructable>: MockFunctionWithBoundDefaultReturn<T, ReturnType> {
    init(bindings: Bindings) {
        super.init(bindings: bindings, defaultReturn: ReturnType())
    }
}

class MockFunctionWithoutDefaultReturn<T: Hashable, ReturnType>: _MockFunction<T, ReturnType> {
    override init(bindings: Bindings) { // FIXME: why is this needed?
        super.init(bindings: bindings)
    }

    func orElse(defaultReturn: ReturnType) -> MockFunctionWithBoundDefaultReturn<T, ReturnType> {
        return MockFunctionWithBoundDefaultReturn<T, ReturnType>(bindings: self.bindings, defaultReturn: defaultReturn)
    }
}

class Binding<T where T: Hashable, T: Equatable> {
    let boundArgument: T

    init(_ arg: T) {
        boundArgument = arg
    }

    func then<ReturnType>(returnValue: ReturnType) -> MockFunctionWithoutDefaultReturn<T, ReturnType> {
        return MockFunctionWithoutDefaultReturn<T, ReturnType>(bindings: [self: returnValue])
    }

    func then<ReturnType: Hashable>(returnValue: ReturnType) -> MockFunction<T, ReturnType> {
        return MockFunction<T, ReturnType>(bindings: [self: returnValue])
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
    func verifyNever<T: Hashable, ReturnType>(mockFunc: MockFunction<T, ReturnType>,
        inFile filePath: String = __FILE__,
        atLine lineNumber: UInt = __LINE__) -> () {
            if (mockFunc.invocationCount != 0) {
                self.recordFailureWithDescription("Mocked function was called more than zero times", inFile: filePath, atLine: lineNumber, expected: true)
            }
    }

    func verifyAtLeastOnce<T: Hashable, ReturnType>(mockFunc: MockFunction<T, ReturnType>,
        inFile filePath: String = __FILE__,
        atLine lineNumber: UInt = __LINE__) -> () {
            if (mockFunc.invocationCount < 1) {
                self.recordFailureWithDescription("Mocked function was not called at least once", inFile: filePath, atLine: lineNumber, expected: true)
            }
    }
}
