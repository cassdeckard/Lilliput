import Foundation
import XCTest

protocol MockFunctionType {
    associatedtype ResultType
    associatedtype BoundResultType
    
    func addBoundResult(_ newBoundResult: BoundResultType)
}

class MockFunction<B: BindingType, R>: MockFunctionType {
    typealias A = B.ArgumentType
    typealias ResultType = R
    typealias BoundResultType = BoundResult<B, R>
    
    var boundResults = [BoundResultType]()
    let defaultValue: R
    
    init(withDefaultValue defaultValue: R) {
        self.defaultValue = defaultValue
        
    }
    
    func addBoundResult(_ newBoundResult: BoundResultType) {
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

extension MockFunction where B.ArgumentType: Equatable {
    func when(_ argA: A) -> NewBinding<A, EqualsMatcher<A>, MockFunction> {
        let tc: XCTestCase = boundResults.first!.binding.testCase // TODO make better
        
        return NewBinding.create(testCase: tc, target: self, argA) as! NewBinding<B.ArgumentType, EqualsMatcher<B.ArgumentType>, MockFunction>
    }
}
