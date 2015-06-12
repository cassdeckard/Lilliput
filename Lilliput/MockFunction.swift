import Foundation
import XCTest

protocol Mock { }

class _MockFunction<A: Equatable, B: Equatable, ReturnType>: Mock {
    typealias Signature = (A, B) -> ReturnType
    typealias Signature_ = (A) -> ReturnType
    typealias TBinding = Binding<A, B>
    typealias Bindings = [(TBinding, ReturnType)]

    let testCase: XCTestCase
    var bindings: Bindings

    init(testCase: XCTestCase, bindings: Bindings) {
        self.testCase = testCase
        self.bindings = bindings
    }

    func addBinding(binding binding: TBinding, returnValue: ReturnType) {
        self.bindings.append((binding, returnValue))
    }
}

class MockFunction<A: Equatable, B:Equatable, ReturnType>: _MockFunction<A, B, ReturnType> {
    var invocationCount = 0
    let defaultReturn: ReturnType

    init(testCase: XCTestCase, bindings: Bindings, defaultReturn: ReturnType) {
        self.defaultReturn = defaultReturn
        super.init(testCase: testCase, bindings: bindings)
    }

    func when(argA: Any, _ argB: Any) -> MockWithBinding<A, B, ReturnType> {
        let newBinding = Binding<A, B>(testCase: self.testCase, argA, argB)
        return MockWithBinding(mock: self, binding: newBinding)
    }

    func when(argA: Any) -> MockWithBinding<A, NoArgument, ReturnType> {
        let newBinding = Binding<A, NoArgument>(testCase: self.testCase, argA, NoArgument())
        return MockWithBinding(mock: self, binding: newBinding)
    }
}

class MockFunctionUsingDefaultConstructorForReturn<A: Equatable, B: Equatable, ReturnType: DefaultConstructible>: MockFunction<A, B, ReturnType> {
    init(testCase: XCTestCase, bindings: Bindings = []) {
        super.init(testCase: testCase, bindings: bindings, defaultReturn: ReturnType())
    }
}

class MockFunctionWithoutDefaultReturn<A: Equatable, B: Equatable, ReturnType>: _MockFunction<A, B, ReturnType> {
    override init(testCase: XCTestCase, bindings: Bindings = []) { // FIXME: why is this needed?
        super.init(testCase: testCase, bindings: bindings)
    }

    func orElse(defaultReturn: ReturnType) -> MockFunction<A, B, ReturnType> {
        return MockFunction<A, B, ReturnType>(testCase: self.testCase, bindings: self.bindings, defaultReturn: defaultReturn)
    }
}

// MARK: Unboxing

func _unbox<A: Equatable, B: Equatable, ReturnType>(mock: MockFunction<A, B, ReturnType>, argA: A, argB: B) -> ReturnType {
    mock.invocationCount++
    for (binding, returnValue) in mock.bindings {
        if binding.matches(argA, argB) {
            return returnValue
        }
    }
    return mock.defaultReturn
}

func unbox<A: Equatable, B: Equatable, ReturnType>(mock: MockFunction<A, B, ReturnType>) -> MockFunction<A, B, ReturnType>.Signature {
    return { _unbox(mock, argA: $0, argB: $1) }
}

func unbox<A: Equatable, ReturnType>(mock: MockFunction<A, NoArgument, ReturnType>) -> MockFunction<A, NoArgument, ReturnType>.Signature_ {
    return { _unbox(mock, argA: $0, argB: NoArgument()) }
}