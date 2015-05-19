import XCTest

class Lilliput1ArgumentTests: XCTestCase {

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
        let testObject = TestClass(stringFilter: unbox(mockStringFilter))

        let result = testObject.useStringFilter("foo")

        verifyAtLeastOnce(mockStringFilter)
        XCTAssertEqual(result, "bar")
    }

    func test_multipleWhenThens() {
        let mockStringFilter = when("foo").then("bar")

        let binding = mockStringFilter.when("bar")
        binding.then("baz")
        let testObject = TestClass(stringFilter: unbox(mockStringFilter))

        let result1 = testObject.useStringFilter("foo")
        let result2 = testObject.useStringFilter("bar")
        let defaultResult = testObject.useStringFilter("baz")

        verifyAtLeastOnce(mockStringFilter)
        XCTAssertEqual(result1, "bar")
        XCTAssertEqual(result2, "baz")
        XCTAssertEqual(defaultResult, "")
    }

    func test_mockBuilderSyntax() {
        let aMock = mock(String).returning(String)
    }

    func test_any() {
        let mockStringFilter = mock(String).returning(String)
        mockStringFilter.when("foo").then("bar")
        mockStringFilter.when(any(String)).then("baz")
        let testObject = TestClass(stringFilter: unbox(mockStringFilter))

        let result1 = testObject.useStringFilter("foo")
        let resultAny = testObject.useStringFilter("NOT FOO")

        verifyAtLeastOnce(mockStringFilter)
        XCTAssertEqual(result1, "bar")
        XCTAssertEqual(resultAny, "baz")
    }

    // ReturnType tests

    func test_returnType_canBeNotDefaultConstructible_ifDefaultIsProvided() {
        let mockStringToInt = when("foo").then(1).orElse(2)
        let testObject = TestClass(stringToInt: unbox(mockStringToInt))

        let fooResult = testObject.useStringToInt("foo")
        let defaultResult = testObject.useStringToInt("NOT FOO")

        verifyAtLeastOnce(mockStringToInt)
        XCTAssertEqual(fooResult, 1)
        XCTAssertEqual(defaultResult, 2)
    }

    func test_returnType_canHaveDefaultSet_evenIfReturnTypeIsDefaultConstructible() {
        let mockStringFilter = when("foo").then("bar").orElse("baz")
        let testObject = TestClass(stringFilter: unbox(mockStringFilter))

        let fooResult = testObject.useStringFilter("foo")
        let defaultResult = testObject.useStringFilter("NOT FOO")

        verifyAtLeastOnce(mockStringFilter)
        XCTAssertEqual(fooResult, "bar")
        XCTAssertEqual(defaultResult, "baz")
    }

    // Verify tests

    func test_verifyNever_succeedsWhenMockIsNeverInvoked() {
        let mockStringFilter = when("foo").then("bar")
        let testObject = TestClass(stringFilter: unbox(mockStringFilter))

        verifyNever(mockStringFilter)
    }
}
