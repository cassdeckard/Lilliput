import Foundation
import XCTest

class _MockFunction2<A: Equatable, B: Equatable, ReturnType> {
    typealias Signature = (A, B) -> ReturnType
    typealias TBinding = Binding2<A, B>
    typealias Bindings = [(TBinding, ReturnType)]

    var bindings: Bindings

    init(bindings: Bindings) {
        self.bindings = bindings
    }
}

class MockFunction2<A: Equatable, B:Equatable, ReturnType>: _MockFunction2<A, B, ReturnType> {
    var invocationCount = 0
    let defaultReturn: ReturnType

    init(bindings: Bindings, defaultReturn: ReturnType) {
        self.defaultReturn = defaultReturn
        super.init(bindings: bindings)
    }

    func unbox() -> Signature {
        return {
            (argA: A, argB: B) in
            self.invocationCount++
            for (binding, returnValue) in self.bindings {
                if argA == binding.boundArgumentA &&
                   argB == binding.boundArgumentB {
                    return returnValue
                }
            }
            return self.defaultReturn
        }
    }
}

class MockFunction2UsingDefaultConstructorForReturn<A: Equatable, B: Equatable, ReturnType: DefaultConstructible>: MockFunction2<A, B, ReturnType> {
    init(bindings: Bindings) {
        super.init(bindings: bindings, defaultReturn: ReturnType())
    }
}

class MockFunction2WithoutDefaultReturn<A: Equatable, B: Equatable, ReturnType>: _MockFunction2<A, B, ReturnType> {
    override init(bindings: Bindings) { // FIXME: why is this needed?
        super.init(bindings: bindings)
    }

    func orElse(defaultReturn: ReturnType) -> MockFunction2<A, B, ReturnType> {
        return MockFunction2<A, B, ReturnType>(bindings: self.bindings, defaultReturn: defaultReturn)
    }
}

// MARK: Bindings

class Binding2<A: Equatable, B: Equatable>: Binding1<A> {
    let boundArgumentB: B

    init(_ argA: A, _ argB: B) {
        boundArgumentB = argB
        super.init(argA)
    }

    func then<ReturnType>(returnValue: ReturnType) -> MockFunction2WithoutDefaultReturn<A, B, ReturnType> {
        return MockFunction2WithoutDefaultReturn<A, B, ReturnType>(bindings: [(self, returnValue)])
    }

    func then<ReturnType>(returnValue: ReturnType) -> MockFunction2UsingDefaultConstructorForReturn<A, B, ReturnType> {
        return MockFunction2UsingDefaultConstructorForReturn<A, B, ReturnType>(bindings: [(self, returnValue)])
    }
}

// MARK: Syntactic Sugar

func when<A: Equatable, B: Equatable>(argA: A, argB: B) -> Binding2<A, B> {
    return Binding2(argA, argB)
}

extension XCTestCase {
    func verifyNever<A: Equatable, B: Equatable, ReturnType>(mockFunc: MockFunction2<A, B, ReturnType>,
        inFile filePath: String = __FILE__,
        atLine lineNumber: UInt = __LINE__) -> () {
            if (mockFunc.invocationCount != 0) {
                self.recordFailureWithDescription("Mocked function was called more than zero times", inFile: filePath, atLine: lineNumber, expected: true)
            }
    }

    func verifyAtLeastOnce<A: Equatable, B: Equatable, ReturnType>(mockFunc: MockFunction2<A, B, ReturnType>,
        inFile filePath: String = __FILE__,
        atLine lineNumber: UInt = __LINE__) -> () {
            if (mockFunc.invocationCount < 1) {
                self.recordFailureWithDescription("Mocked function was not called at least once", inFile: filePath, atLine: lineNumber, expected: true)
            }
    }
}