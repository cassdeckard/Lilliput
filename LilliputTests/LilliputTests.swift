import XCTest

class LilliputTests: XCTestCase {

    class TestClass {
        typealias StringFilter = (String) -> (String)
        let stringFilter : StringFilter

        init(stringFilter : StringFilter) {
            self.stringFilter = stringFilter
        }

        func useStringFilter(inString: String) -> String {
            return self.stringFilter(inString)
        }
    }

    func testBasicFunctionMocking() {
        let mockStringFilter = when("foo").then("bar")
        let testObject = TestClass(stringFilter: mockStringFilter.unbox())

        let result = testObject.useStringFilter("foo")

        verifyAtLeastOnce(mockStringFilter)
        XCTAssertEqual(result, "bar")
    }

    func testVerifyNever() {
        let mockStringFilter = when("foo").then("bar")
        let testObject = TestClass(stringFilter: mockStringFilter.unbox())

        verifyNever(mockStringFilter)
    }
}
