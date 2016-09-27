import Foundation
import XCTest

class MockFunction<A: Equatable, R> {
    let binding: Binding<A>
    let returnValue: R
    let defaultValue: R
    
    init(binding: Binding<A>, to returnValue: R, withDefault defaultValue: R) {
        self.binding = binding
        self.returnValue = returnValue
        self.defaultValue = defaultValue
    }
    
    func unbox() -> (A) -> (R) {
        return {
            if self.binding.matches($0) {
                return self.returnValue
            }
            else {
                return self.defaultValue
            }
        }
    }
}

class MockFunctionWithoutDefault<A: Equatable, R> {
    let binding: Binding<A>
    let returnValue: R
    
    init(binding: Binding<A>, to returnValue: R) {
        self.binding = binding
        self.returnValue = returnValue
    }
    
    func `else`(_ defaultValue: R) -> MockFunction<A, R> {
        return MockFunction(binding: self.binding, to: returnValue, withDefault: defaultValue)
    }
}

class Binding<A: Equatable>: NSObject {
    let argA: A
    
    init(testCase: XCTestCase, _ argA: A) {
        self.argA = argA
    }
    
    func then<R>(_ returnValue: R) -> MockFunctionWithoutDefault<A, R> {
        return MockFunctionWithoutDefault(binding: self, to: returnValue)
    }
    
    func matches(_ argA: A) -> Bool {
        return self.argA == argA
    }
}
