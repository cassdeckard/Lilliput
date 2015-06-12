import XCTest

class BindingImplementationTests: XCTestCase {

    // We only care that this compiles
    func test_bindingImplCanBeInitializedWithRealOrAnyWrappedType() {
        _ = _Binding<Int>(2)
        _ = _Binding<Int>(any(Int))
    }
}
