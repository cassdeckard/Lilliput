import Foundation
import XCTest

protocol Mock { }

class NoArgument: Equatable { }

func ==(lhs: NoArgument, rhs: NoArgument) -> Bool {
    return true
}

class ArgumentBinder<T: Equatable> {
    let arg: T?
    init(_ arg: T) {
        self.arg = arg
    }
}

func ==<T: Equatable>(lhs: ArgumentBinder<T>, rhs: T) -> Bool {
    return lhs.arg == rhs
}

// MARK: MockFunction

class _MockFunction<A: Equatable, B: Equatable, ReturnType>: Mock {
    typealias Signature = (A, B) -> ReturnType
    typealias Signature_ = (A) -> ReturnType
    typealias TBinding = Binding<A, B>
    typealias Bindings = [(TBinding, ReturnType)]

    var bindings: Bindings

    init(bindings: Bindings) {
        self.bindings = bindings
    }

    func addBinding(#binding: TBinding, returnValue: ReturnType) {
        self.bindings.append((binding, returnValue))
    }
}

class MockFunction<A: Equatable, B:Equatable, ReturnType>: _MockFunction<A, B, ReturnType> {
    var invocationCount = 0
    let defaultReturn: ReturnType

    init(bindings: Bindings, defaultReturn: ReturnType) {
        self.defaultReturn = defaultReturn
        super.init(bindings: bindings)
    }

    func when(argA: A, _ argB: B) -> Binding<A, B> {
        return Binding(argA, argB, mock: self)
    }

    func when(argA: A) -> Binding<A, NoArgument> {
        return Binding(argA, NoArgument(), mock: self)
    }
}

class MockFunctionUsingDefaultConstructorForReturn<A: Equatable, B: Equatable, ReturnType: DefaultConstructible>: MockFunction<A, B, ReturnType> {
    init(bindings: Bindings) {
        super.init(bindings: bindings, defaultReturn: ReturnType())
    }
}

class MockFunctionWithoutDefaultReturn<A: Equatable, B: Equatable, ReturnType>: _MockFunction<A, B, ReturnType> {
    override init(bindings: Bindings) { // FIXME: why is this needed?
        super.init(bindings: bindings)
    }

    func orElse(defaultReturn: ReturnType) -> MockFunction<A, B, ReturnType> {
        return MockFunction<A, B, ReturnType>(bindings: self.bindings, defaultReturn: defaultReturn)
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
    return { _unbox(mock, $0, $1) }
}

func unbox<A: Equatable, ReturnType>(mock: MockFunction<A, NoArgument, ReturnType>) -> MockFunction<A, NoArgument, ReturnType>.Signature_ {
    return { _unbox(mock, $0, NoArgument()) }
}

// MARK: Bindings

class Binding<A: Equatable, B: Equatable> {
    var mock: Mock?
    let boundArgumentA: ArgumentBinder<A>
    let boundArgumentB: ArgumentBinder<B>

    init(_ argA: A, _ argB: B) {
        boundArgumentA = ArgumentBinder<A>(argA)
        boundArgumentB = ArgumentBinder<B>(argB)
    }

    convenience init(_ argA: A, _ argB: B, mock: Mock) {
        self.init(argA, argB)
        self.mock = mock
    }

    func then<ReturnType>(returnValue: ReturnType) -> MockFunctionWithoutDefaultReturn<A, B, ReturnType> {
        if let mock = self.mock as? MockFunctionWithoutDefaultReturn<A, B, ReturnType> {
            mock.addBinding(binding: self, returnValue: returnValue)
            return mock
        }
        return MockFunctionWithoutDefaultReturn<A, B, ReturnType>(bindings: [(self, returnValue)])
    }

    func then<ReturnType>(returnValue: ReturnType) -> MockFunctionUsingDefaultConstructorForReturn<A, B, ReturnType> {
        if let mock = self.mock as? MockFunctionUsingDefaultConstructorForReturn<A, B, ReturnType> {
            mock.addBinding(binding: self, returnValue: returnValue)
            return mock
        }
        return MockFunctionUsingDefaultConstructorForReturn<A, B, ReturnType>(bindings: [(self, returnValue)])
    }

    func matches(argA: A, _ argB: B) -> Bool {
        return boundArgumentA.arg == argA &&
               boundArgumentB.arg == argB
    }
}

// MARK: Syntactic Sugar

func when<A: Equatable, B: Equatable>(argA: A, argB: B) -> Binding<A, B> {
    return Binding(argA, argB)
}

func when<A: Equatable>(argA: A) -> Binding<A, NoArgument> {
    return Binding(argA, NoArgument())
}

extension XCTestCase {
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