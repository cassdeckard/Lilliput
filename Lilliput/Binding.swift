import Foundation
import XCTest

class MockFunction<A, R> {
    let returnValue: R
    
    init(binding: Binding<A>, to value: R) {
        returnValue = value
    }
    
    func unbox() -> (A) -> (R) {
        return { _ in self.returnValue }
    }
}

class Binding<A>: NSObject {
    init(testCase: XCTestCase, _ argA: A) {
        
    }
    
    func then<R>(_ returnValue: R) -> MockFunction<A, R> {
        return MockFunction(binding: self, to: returnValue)
    }
}
