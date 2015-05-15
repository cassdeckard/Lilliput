import XCTest

class LilliputTests: XCTestCase {

    class TestClass {
        typealias StringFilter = (String) -> (String)
        typealias StringToInt = (String) -> (Int)

        var stringFilter : StringFilter!
        var stringToInt : StringToInt!

        init(stringFilter : StringFilter) {
            self.stringFilter = stringFilter
        }

        init(stringToInt : StringToInt) {
            self.stringToInt = stringToInt
        }

        func useStringFilter(inString: String) -> String {
            return self.stringFilter(inString)
        }

        func useStringToInt(inString: String) -> Int {
            return self.stringToInt(inString)
        }
    }

    func test_basicFunctionMocking() {
        let mockStringFilter = when("foo").then("bar")
        let testObject = TestClass(stringFilter: mockStringFilter.unbox())

        let result = testObject.useStringFilter("foo")

        verifyAtLeastOnce(mockStringFilter)
        XCTAssertEqual(result, "bar")
    }

    // ReturnType tests

    func test_returnType_canBeNotDefaultConstructable_ifDefaultIsProvided() {
        let mockStringToInt = when("foo").then(1).orElse(2)
        let testObject = TestClass(stringToInt: mockStringToInt.unbox())

        let fooResult = testObject.useStringToInt("foo")
        let defaultResult = testObject.useStringToInt("NOT FOO")

        XCTAssertEqual(fooResult, 1)
        XCTAssertEqual(defaultResult, 2)
    }

    func test_returnType_canHaveDefaultSet_evenIfReturnTypeIsDefaultConstructible() {
        let mockStringFilter = when("foo").then("bar").orElse("baz")
        let testObject = TestClass(stringFilter: mockStringFilter.unbox())

        let fooResult = testObject.useStringFilter("foo")
        let defaultResult = testObject.useStringFilter("NOT FOO")

        XCTAssertEqual(fooResult, "bar")
        XCTAssertEqual(defaultResult, "baz")
    }

    // Verify tests

    func test_verifyNever_succeedsWhenMockIsNeverInvoked() {
        let mockStringFilter = when("foo").then("bar")
        let testObject = TestClass(stringFilter: mockStringFilter.unbox())

        verifyNever(mockStringFilter)
    }
}
