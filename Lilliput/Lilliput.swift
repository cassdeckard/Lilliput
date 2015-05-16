import Foundation
import XCTest

class _MockFunction1<A: Equatable, ReturnType> {
    typealias Signature = (A) -> ReturnType
    typealias TBinding = Binding1<A>
    typealias Bindings = [(TBinding, ReturnType)]

    var bindings: Bindings

    init(bindings: Bindings) {
        self.bindings = bindings
    }
}

class MockFunction1<A: Equatable, ReturnType>: _MockFunction1<A, ReturnType> {
    var invocationCount = 0
    let defaultReturn: ReturnType

    init(bindings: Bindings, defaultReturn: ReturnType) {
        self.defaultReturn = defaultReturn
        super.init(bindings: bindings)
    }

    func unbox() -> Signature {
        return {
            (arg: A) in
            self.invocationCount++
            for (binding, returnValue) in self.bindings {
                if arg == binding.boundArgumentA {
                    return returnValue
                }
            }
            return self.defaultReturn
        }
    }
}

class MockFunction1UsingDefaultConstructorForReturn<A: Equatable, ReturnType: DefaultConstructible>: MockFunction1<A, ReturnType> {
    init(bindings: Bindings) {
        super.init(bindings: bindings, defaultReturn: ReturnType())
    }
}

class MockFunction1WithoutDefaultReturn<A: Equatable, ReturnType>: _MockFunction1<A, ReturnType> {
    override init(bindings: Bindings) { // FIXME: why is this needed?
        super.init(bindings: bindings)
    }

    func orElse(defaultReturn: ReturnType) -> MockFunction1<A, ReturnType> {
        return MockFunction1<A, ReturnType>(bindings: self.bindings, defaultReturn: defaultReturn)
    }
}

// MARK: Bindings

class Binding1<A: Equatable> {
    let boundArgumentA: A

    init(_ argA: A) {
        boundArgumentA = argA
    }

    func then<ReturnType>(returnValue: ReturnType) -> MockFunction1WithoutDefaultReturn<A, ReturnType> {
        return MockFunction1WithoutDefaultReturn<A, ReturnType>(bindings: [(self, returnValue)])
    }

    func then<ReturnType>(returnValue: ReturnType) -> MockFunction1UsingDefaultConstructorForReturn<A, ReturnType> {
        return MockFunction1UsingDefaultConstructorForReturn<A, ReturnType>(bindings: [(self, returnValue)])
    }
}

// MARK: Syntactic Sugar

func when<A: Equatable>(arg: A) -> Binding1<A> {
    return Binding1(arg)
}

extension XCTestCase {
    func verifyNever<A: Equatable, ReturnType>(mockFunc: MockFunction1<A, ReturnType>,
        inFile filePath: String = __FILE__,
        atLine lineNumber: UInt = __LINE__) -> () {
            if (mockFunc.invocationCount != 0) {
                self.recordFailureWithDescription("Mocked function was called more than zero times", inFile: filePath, atLine: lineNumber, expected: true)
            }
    }

    func verifyAtLeastOnce<A: Equatable, ReturnType>(mockFunc: MockFunction1<A, ReturnType>,
        inFile filePath: String = __FILE__,
        atLine lineNumber: UInt = __LINE__) -> () {
            if (mockFunc.invocationCount < 1) {
                self.recordFailureWithDescription("Mocked function was not called at least once", inFile: filePath, atLine: lineNumber, expected: true)
            }
    }
}
