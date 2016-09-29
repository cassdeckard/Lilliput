import Foundation
import XCTest

class BoundResult<B: BindingType, R> {
    typealias A = B.ArgumentType
    let binding: B
    let returnValue: R
    
    init(binding: B, to returnValue: R) {
        self.binding = binding
        self.returnValue = returnValue
    }
    
    func `else`(_ defaultValue: R) -> MockFunction<B, R> {
        let mockFunction: MockFunction<B, R> = MockFunction(withDefaultValue: defaultValue)
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
