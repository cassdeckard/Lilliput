import Foundation

class MockWithBinding<A: Equatable, B: Equatable, ReturnType> {
    typealias BindingT = Binding<A, B>
    var mock: Mock
    var binding: BindingT

    init(mock: Mock, binding: BindingT) {
        self.binding = binding
        self.mock = mock
    }

    func then<ReturnType>(returnValue: ReturnType) -> MockFunctionWithoutDefaultReturn<A, B, ReturnType> {
        if let mock = self.mock as? MockFunctionWithoutDefaultReturn<A, B, ReturnType> {
            mock.addBinding(binding: binding, returnValue: returnValue)
            return mock
        }
        return MockFunctionWithoutDefaultReturn<A, B, ReturnType>(testCase: binding.testCase, bindings: [(binding, returnValue)])
    }

    func then<ReturnType>(returnValue: ReturnType) -> MockFunctionUsingDefaultConstructorForReturn<A, B, ReturnType> {
        if let mock = self.mock as? MockFunctionUsingDefaultConstructorForReturn<A, B, ReturnType> {
            mock.addBinding(binding: binding, returnValue: returnValue)
            return mock
        }
        return MockFunctionUsingDefaultConstructorForReturn<A, B, ReturnType>(testCase: binding.testCase, bindings: [(binding, returnValue)])
    }
}