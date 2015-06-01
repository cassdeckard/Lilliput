import Foundation
import XCTest

protocol Mock { }

class NoArgument: Equatable { }

func ==(lhs: NoArgument, rhs: NoArgument) -> Bool {
    return true
}

class ArgumentBinder<T: Equatable> {
    let arg: T
    init(_ arg: T) {
        self.arg = arg
    }
}

func ==<T: Equatable>(lhs: ArgumentBinder<T>, rhs: T) -> Bool {
    return lhs.arg == rhs
}

// MARK: Any

class AnyArgument<T> {}

func any<T>(t: T.Type) -> AnyArgument<T> {
    return AnyArgument<T>()
}

class _Binding<A: Equatable> {
    let realSelf: ArgumentBinder<A>?
    let anySelf: AnyArgument<A>?

    static func valueOrAnyArgument(a: Any) -> (ArgumentBinder<A>?, AnyArgument<A>?) {
        var value: ArgumentBinder<A>? = nil
        var any: AnyArgument<A>? = nil
        if let a = a as? AnyArgument<A> {
            any = a
        } else if let a = a as? A {
            value = ArgumentBinder<A>(a)
        }
        return (value, any)
    }

    init(_ a: Any) {
        (realSelf, anySelf) = self.dynamicType.valueOrAnyArgument(a)
    }

    func matches(a: A) -> Bool {
        var result = false
        if let realSelf = realSelf {
            result = (realSelf.arg == a)
        }
        if let _ = anySelf {
            result = true
        }
        return result
    }

    func isValid() -> Bool {
        return realSelf != nil || anySelf != nil
    }
}

// MARK: MockFunction

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

// MARK: Bindings

class Binding<A: Equatable, B: Equatable> {
    let testCase: XCTestCase
    let boundArgumentA: _Binding<A>
    let boundArgumentB: _Binding<B>

    init(testCase: XCTestCase, _ argA: Any, _ argB: Any) {
        self.testCase = testCase
        boundArgumentA = _Binding<A>(argA)
        boundArgumentB = _Binding<B>(argB)
        testCase.verifyBoundArgumentsAreValid(self)
    }

    func then<ReturnType>(returnValue: ReturnType) -> MockFunctionWithoutDefaultReturn<A, B, ReturnType> {
        return MockFunctionWithoutDefaultReturn<A, B, ReturnType>(testCase: testCase, bindings: [(self, returnValue)])
    }

    func then<ReturnType>(returnValue: ReturnType) -> MockFunctionUsingDefaultConstructorForReturn<A, B, ReturnType> {
        return MockFunctionUsingDefaultConstructorForReturn<A, B, ReturnType>(testCase: testCase, bindings: [(self, returnValue)])
    }

    func matches(argA: A, _ argB: B) -> Bool {
        return boundArgumentA.matches(argA) &&
            boundArgumentB.matches(argB)
    }
}

class MockWithBinding<A: Equatable, B: Equatable, ReturnType> {
    typealias BindingT = Binding<A, B>
    var mock: Mock
    var binding: BindingT

    init(mock: Mock, binding: BindingT) {
        self.binding = binding
        self.mock = mock
    }

    func then<ReturnType>(returnValue: ReturnType) -> MockFunctionWithoutDefaultReturn<A, B, ReturnType> {
        if let mock = self.mock as? MockFunctionWithoutDefaultReturn<A, B, ReturnType> {
            mock.addBinding(binding: binding, returnValue: returnValue)
            return mock
        }
        return MockFunctionWithoutDefaultReturn<A, B, ReturnType>(testCase: binding.testCase, bindings: [(binding, returnValue)])
    }

    func then<ReturnType>(returnValue: ReturnType) -> MockFunctionUsingDefaultConstructorForReturn<A, B, ReturnType> {
        if let mock = self.mock as? MockFunctionUsingDefaultConstructorForReturn<A, B, ReturnType> {
            mock.addBinding(binding: binding, returnValue: returnValue)
            return mock
        }
        return MockFunctionUsingDefaultConstructorForReturn<A, B, ReturnType>(testCase: binding.testCase, bindings: [(binding, returnValue)])
    }
}

// MARK: Syntactic Sugar

class MockBuilder<A: Equatable, B: Equatable> {
    let testCase: XCTestCase

    init(testCase: XCTestCase) {
        self.testCase = testCase
    }

    func returning<ReturnType: DefaultConstructible>(returnType: ReturnType.Type) -> MockFunctionUsingDefaultConstructorForReturn<A, B, ReturnType> {
        return MockFunctionUsingDefaultConstructorForReturn<A, B, ReturnType>(testCase: self.testCase)
    }


    func returning<ReturnType>(returnType: ReturnType.Type) -> MockFunctionWithoutDefaultReturn<A, B, ReturnType> {
        return MockFunctionWithoutDefaultReturn<A, B, ReturnType>(testCase: self.testCase)
    }
}

extension XCTestCase {
    func mock<A: Equatable, B: Equatable>(a: A.Type, _ b: B.Type) -> MockBuilder<A, B> {
        return MockBuilder<A, B>(testCase: self)
    }

    func mock<A: Equatable>(a: A.Type) -> MockBuilder<A, NoArgument> {
        return MockBuilder<A, NoArgument>(testCase: self)
    }

    func when<A: Equatable, B: Equatable>(argA: A, _ argB: B) -> Binding<A, B> {
        return Binding(testCase: self, argA, argB)
    }

    func when<A: Equatable>(argA: A) -> Binding<A, NoArgument> {
        return Binding(testCase: self, argA, NoArgument())
    }

    func verifyBoundArgumentsAreValid<A: Equatable, B: Equatable>(binding: Binding<A, B>,
        inFile filePath: String = __FILE__,
        atLine lineNumber: UInt = __LINE__) -> () {
            if !(binding.boundArgumentA.isValid() &&
                binding.boundArgumentB.isValid()) {
                    self.recordFailureWithDescription("One or more bound arguments is not valid", inFile: filePath, atLine: lineNumber, expected: true)
            }
    }

    func verifyNever<A: Equatable, B: Equatable, ReturnType>(mockFunc: MockFunction<A, B, ReturnType>,
        inFile filePath: String = __FILE__,
        atLine lineNumber: UInt = __LINE__) -> () {
            if (mockFunc.invocationCount != 0) {
                self.recordFailureWithDescription("Mocked function was called more than zero times", inFile: filePath, atLine: lineNumber, expected: true)
            }
    }

    func verifyAtLeastOnce<A: Equatable, B: Equatable, ReturnType>(mockFunc: MockFunction<A, B, ReturnType>,
        inFile filePath: String = __FILE__,
        atLine lineNumber: UInt = __LINE__) -> () {
            if (mockFunc.invocationCount < 1) {
                self.recordFailureWithDescription("Mocked function was not called at least once", inFile: filePath, atLine: lineNumber, expected: true)
            }
    }
}