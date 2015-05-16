import XCTest

class LilliputOneArgumentTests: XCTestCase {

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

    // ReturnType tests

    func test_returnType_canBeNotDefaultConstructable_ifDefaultIsProvided() {
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


class LilliputTwoArgumentTests: XCTestCase {

    class TestClass {
        typealias StringIntToString = (String, Int) -> (String)
        typealias StringsToInt = (String, String) -> (Int)

        var stringIntToString : StringIntToString!
        var stringsToInt : StringsToInt!

        init(stringIntToString : StringIntToString) {
            self.stringIntToString = stringIntToString
        }

        init(stringsToInt : StringsToInt) {
            self.stringsToInt = stringsToInt
        }

        func useStringIntToString(lhs: String, _ rhs: Int) -> String {
            return self.stringIntToString(lhs, rhs)
        }

        func useStringsToInt(lhs: String, _ rhs: String) -> Int {
            return self.stringsToInt(lhs, rhs)
        }
    }

    func test_basicFunctionMocking() {
        let mockStringIntToString = when("foo", 42).then("bar")
        let testObject = TestClass(stringIntToString: unbox(mockStringIntToString))

        let result = testObject.useStringIntToString("foo", 42)

        verifyAtLeastOnce(mockStringIntToString)
        XCTAssertEqual(result, "bar")
    }

    // ReturnType tests

    func test_returnType_canBeNotDefaultConstructable_ifDefaultIsProvided() {
        let mockStringsToInt = when("foo", "bar").then(1).orElse(2)

        let testObject = TestClass(stringsToInt: unbox(mockStringsToInt))

        let fooBarResult = testObject.useStringsToInt("foo", "bar")
        let defaultResult = testObject.useStringsToInt("foo", "NOT BAR")

        verifyAtLeastOnce(mockStringsToInt)
        XCTAssertEqual(fooBarResult, 1)
        XCTAssertEqual(defaultResult, 2)
    }

    func test_returnType_canHaveDefaultSet_evenIfReturnTypeIsDefaultConstructible() {
        let mockStringIntToString = when("foo", 42).then("bar").orElse("baz")
        let testObject = TestClass(stringIntToString: unbox(mockStringIntToString))

        let foo42Result = testObject.useStringIntToString("foo", 42)
        let defaultResult1 = testObject.useStringIntToString("foo", 43)
        let defaultResult2 = testObject.useStringIntToString("NOT FOO", 42)

        verifyAtLeastOnce(mockStringIntToString)
        XCTAssertEqual(foo42Result, "bar")
        XCTAssertEqual(defaultResult1, "baz")
        XCTAssertEqual(defaultResult1, "baz")
    }

    // Verify tests

    func test_verifyNever_succeedsWhenMockIsNeverInvoked() {
        let mockStringIntToString = when("foo", 42).then("bar")
        let testObject = TestClass(stringIntToString: unbox(mockStringIntToString))

        verifyNever(mockStringIntToString)
    }
}
