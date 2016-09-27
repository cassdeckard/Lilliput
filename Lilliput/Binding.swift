import Foundation
import XCTest

class MockFunction<A: Equatable, R> {
    typealias BoundResultType = BoundResult<A, R>

    var boundResults = [BoundResultType]()
    let defaultValue: R

    init(withDefaultValue defaultValue: R) {
        self.defaultValue = defaultValue
        
    }
    
    func addBoundResult(_ newBoundResult: BoundResultType) {
        boundResults.append(newBoundResult)
    }
    
    func when(_ argA: A) -> Binding<A> {
        let tc: XCTestCase = boundResults.first!.binding.testCase // TODO make better
        return NewBinding(testCase: tc, target: self, argA)
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

class NewBinding<A: Equatable, R>: Binding<A> {
    typealias TargetType = MockFunction<A, R>
    let target: TargetType
    
    init(testCase: XCTestCase, target: TargetType, _ argA: A) {
        self.target = target
        super.init(testCase: testCase, argA)
    }

    @discardableResult
    override func then<R>(_ returnValue: R) -> BoundResult<A, R> {
        let boundResult: BoundResult<A, R> = BoundResult(binding: self, to: returnValue)
        target.addBoundResult(boundResult as! TargetType.BoundResultType) // Warning is bogus, ignore
        return boundResult
    }
}

class Binding<A: Equatable>: NSObject {
    let testCase: XCTestCase
    let argA: A
    
    init(testCase: XCTestCase, _ argA: A) {
        self.testCase = testCase
        self.argA = argA
    }
    
    func then<R>(_ returnValue: R) -> BoundResult<A, R> {
        return BoundResult(binding: self, to: returnValue)
    }
    
    func matches(_ argA: A) -> Bool {
        return self.argA == argA
    }
}
