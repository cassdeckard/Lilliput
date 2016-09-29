import Foundation
import XCTest

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
