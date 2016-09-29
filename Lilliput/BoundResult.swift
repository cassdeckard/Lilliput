import Foundation
import XCTest

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
