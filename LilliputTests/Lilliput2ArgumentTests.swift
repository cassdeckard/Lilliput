import XCTest

class Lilliput2ArgumentTests: XCTestCase {

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