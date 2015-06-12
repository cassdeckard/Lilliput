import Foundation
import XCTest

class _Binding<A: Equatable> {
    let realSelf: ArgumentBinder<A>?
    let anySelf: AnyArgument<A>?
    let captureSelf: Capture<A>?

    static func valueOrAnyOrCapture(a: Any) -> (ArgumentBinder<A>?, AnyArgument<A>?, Capture<A>?) {
        var value: ArgumentBinder<A>? = nil
        var any: AnyArgument<A>? = nil
        var capture: Capture<A>? = nil
        if let a = a as? AnyArgument<A> {
            any = a
        } else if let a = a as? Capture<A> {
            capture = a
        } else if let a = a as? A {
            value = ArgumentBinder<A>(a)
        }
        return (value, any, capture)
    }

    init(_ a: Any) {
        (realSelf, anySelf, captureSelf) = self.dynamicType.valueOrAnyOrCapture(a)
    }

    func matches(a: A) -> Bool {
        var result = false
        if let realSelf = realSelf {
            result = (realSelf.arg == a)
        }
        if let _ = anySelf {
            result = true
        }
        if let captureSelf = captureSelf {
            captureSelf.capturedArgument = a
            result = true
        }
        return result
    }

    func isValid() -> Bool {
        return realSelf != nil || anySelf != nil || captureSelf != nil
    }
}

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