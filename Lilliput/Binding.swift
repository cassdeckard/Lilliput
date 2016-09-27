import Foundation
import XCTest

class MockFunction<A: Equatable, R> {
    var boundResults = [BoundResult<A, R>]()
    let defaultValue: R
    
    init(withDefaultValue defaultValue: R) {
        self.defaultValue = defaultValue
    }
    
    func addBoundResult(_ newBoundResult: BoundResult<A, R>) {
        boundResults.append(newBoundResult)
    }
    
    func unbox() -> (A) -> (R) {
        return {
            a in
            let maybeResult: R? = self.boundResults.reduce(nil as R?) {
                acc, next in
                guard let resolved = acc else { return next.match(a) }
                return resolved
            }
            guard let result = maybeResult else { return self.defaultValue }
            return result
        }
    }
}

class BoundResult<A: Equatable, R> {
    
    let binding: Binding<A>
    let returnValue: R
    
    init(binding: Binding<A>, to returnValue: R) {
        self.binding = binding
        self.returnValue = returnValue
    }
    
    func `else`(_ defaultValue: R) -> MockFunction<A, R> {
        let mockFunction: MockFunction<A, R> = MockFunction(withDefaultValue: defaultValue)
        mockFunction.addBoundResult(self)
        return mockFunction
    }
    
    func match(_ argA: A) -> R? {
        if binding.matches(argA) {
            return returnValue
        }
        return nil
    }
}

class Binding<A: Equatable>: NSObject {
    let argA: A
    
    init(testCase: XCTestCase, _ argA: A) {
        self.argA = argA
    }
    
    func then<R>(_ returnValue: R) -> BoundResult<A, R> {
        return BoundResult(binding: self, to: returnValue)
    }
    
    func matches(_ argA: A) -> Bool {
        return self.argA == argA
    }
}
