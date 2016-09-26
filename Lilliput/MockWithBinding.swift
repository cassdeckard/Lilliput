import Foundation

class MockWithBinding<A: Equatable, B: Equatable, ReturnType> {
    typealias BindingT = Binding<A, B>
    var mock: Mock
    var binding: BindingT

    init(mock: Mock, binding: BindingT) {
        self.binding = binding
        self.mock = mock
    }

    func then<ReturnType>(_ returnValue: ReturnType) -> MockFunction<A, B, ReturnType> {
        let mockFunction = self.mock as! MockFunction<A, B, ReturnType>
        mockFunction.addBinding(binding: binding, returnValue: returnValue)
        return mockFunction
    }
}
