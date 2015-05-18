import XCTest

class BindingImplementationTests: XCTestCase {

    func test_bindingImplCanBeInitializedWithRealOrAnyWrappedType() {
        let fakeBinding = _Binding<Int>(2)
        let fakeAnyBinding = _Binding<Int>(any(Int))
    }
}
