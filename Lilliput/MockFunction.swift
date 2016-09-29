import Foundation
import XCTest

class MockFunction<B: BindingType, R> {
    typealias A = B.ArgumentType
    typealias Matcher = B.Matcher
    typealias BoundResultType = BoundResult<B, R>
    
    var boundResults = [BoundResultType]()
    let defaultValue: R
    
    init(withDefaultValue defaultValue: R) {
        self.defaultValue = defaultValue
        
    }
    
    func addBoundResult(_ newBoundResult: BoundResultType) {
        boundResults.append(newBoundResult)
    }
    
//    func when(_ argA: A) -> NewBinding<A, R> {
//        let tc: XCTestCase = boundResults.first!.binding.testCase // TODO make better
//        return NewBinding(testCase: tc, target: self, argA)
//    }
    
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
