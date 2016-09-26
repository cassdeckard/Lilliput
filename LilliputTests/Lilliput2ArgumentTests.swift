import XCTest

class Lilliput2ArgumentTests: XCTestCase {

    class TestClass {
        typealias StringIntToString = (String, Int) -> (String)
        typealias StringsToInt = (String, String) -> (Int)
        typealias StringsToNonDefaultConstructibleThing = (String, String) -> (NonDefaultConstructibleThing)

        var stringIntToString : StringIntToString!
        var stringsToInt : StringsToInt!
        var stringsToNonDefaultConstructibleThing : StringsToNonDefaultConstructibleThing!

        init(stringIntToString : @escaping StringIntToString) {
            self.stringIntToString = stringIntToString
        }

        init(stringsToInt : @escaping StringsToInt) {
            self.stringsToInt = stringsToInt
        }

        init(stringsToNonDefaultConstructibleThing : @escaping StringsToNonDefaultConstructibleThing) {
            self.stringsToNonDefaultConstructibleThing = stringsToNonDefaultConstructibleThing
        }

        func useStringIntToString(_ lhs: String, _ rhs: Int) -> String {
            return self.stringIntToString(lhs, rhs)
        }

        func useStringsToInt(_ lhs: String, _ rhs: String) -> Int {
            return self.stringsToInt(lhs, rhs)
        }

        func useStringsToNonDefaultConstructibleThing(_ lhs: String, _ rhs: String) -> NonDefaultConstructibleThing {
            return self.stringsToNonDefaultConstructibleThing(lhs, rhs)
        }
    }

    func test_basicFunctionMocking() {
        let mockStringIntToString = when("foo", 42).then("bar")
        let testObject = TestClass(stringIntToString: unbox(mockStringIntToString))

        let result = testObject.useStringIntToString("foo", 42)

        verifyAtLeastOnce(mockStringIntToString)
        XCTAssertEqual(result, "bar")
    }

    func test_multipleWhenThens() {
        let mockStringIntToString = when("foo", 42).then("bar")
        mockStringIntToString.when("foo", 23).then("baz")
        let testObject = TestClass(stringIntToString: unbox(mockStringIntToString))

        let result1 = testObject.useStringIntToString("foo", 42)
        let result2 = testObject.useStringIntToString("foo", 23)
        let defaultResult = testObject.useStringIntToString("foo", 2)

        verifyAtLeastOnce(mockStringIntToString)
        XCTAssertEqual(result1, "bar")
        XCTAssertEqual(result2, "baz")
        XCTAssertEqual(defaultResult, "")
    }

    func test_mockBuilder_createsMockWithNoMatchers() {
        let aMock = mock(String.self, String.self).returning(String.self)
        XCTAssertEqual(unbox(aMock)("foo", "bar"), "")
    }

    func test_mockBuilder_withNonDefaultConstructibleReturn_createsMockWithNoMatchers() {
        let aMock = mock(String.self, Int.self).returning(NonDefaultConstructibleThing.self).orElse(NonDefaultConstructibleThing(3))
        XCTAssertEqual(unbox(aMock)("foo", 2).int, 3)
    }

    func test_mockCreatedWithMockBuilder_canAddMatchers() {
        let aMock = mock(String.self, Int.self).returning(String.self)
        aMock.when("Foo", 2).then("HI")
        let result = unbox(aMock)("Foo", 2)
        XCTAssertEqual(result, "HI")
    }

    func test_mockCreatedWithMockBuilder_withNonDefaultConstructibleReturn_canAddMatchers() {
        let aMock = mock(String.self, Int.self).returning(NonDefaultConstructibleThing.self).orElse(NonDefaultConstructibleThing(13))
        aMock.when("Foo", 2).then(NonDefaultConstructibleThing(14))
        let result = unbox(aMock)("Foo", 2)
        XCTAssertEqual(result.int, 14)
    }

    func test_any() {
        let mockStringIntToString = when("foo", 2).then("bar")
        mockStringIntToString.when("foo", any(Int.self)).then("baz")
        let testObject = TestClass(stringIntToString: unbox(mockStringIntToString))

        let result1 = testObject.useStringIntToString("foo", 2)
        let resultAny = testObject.useStringIntToString("foo", 3)
        let defaultResult = testObject.useStringIntToString("bar", 2)

        verifyAtLeastOnce(mockStringIntToString)
        XCTAssertEqual(result1, "bar")
        XCTAssertEqual(resultAny, "baz")
        XCTAssertEqual(defaultResult, "")
    }

    // Capturing

    func test_basic_capture() {
        let captureString = capture(String.self)
        let mockStringsToInt = mock(String.self, String.self).returning(Int.self)
        mockStringsToInt.when(captureString, "bar").then(12)

        let result = unbox(mockStringsToInt)("foo", "bar")

        verifyAtLeastOnce(mockStringsToInt)
        XCTAssertEqual(result, 12)
        XCTAssertNotNil(*captureString)
        if let string = *captureString {
            XCTAssertEqual(string, "foo")
        }
    }

    func test_captureArgument_isOnlyCaptured_whenOtherArgumentsMatch() {
        let captureString = capture(String.self)
        let mockStringsToInt = mock(String.self, String.self).returning(Int.self)
        mockStringsToInt.when(captureString, "bar").then(12)

        let result = unbox(mockStringsToInt)("foo", "BAR")

        verifyAtLeastOnce(mockStringsToInt)
        XCTAssertEqual(result, 0)
        XCTAssertNil(*captureString)
    }

    // ReturnType tests

    func test_returnType_canBeNotDefaultConstructible_ifDefaultIsProvided() {
        let mockStringsToNonDefaultConstructibleThing = when("foo", "bar").then(NonDefaultConstructibleThing(1)).orElse(NonDefaultConstructibleThing(2))

        let testObject = TestClass(stringsToNonDefaultConstructibleThing: unbox(mockStringsToNonDefaultConstructibleThing))

        let fooBarResult = testObject.useStringsToNonDefaultConstructibleThing("foo", "bar")
        let defaultResult = testObject.useStringsToNonDefaultConstructibleThing("foo", "NOT BAR")

        verifyAtLeastOnce(mockStringsToNonDefaultConstructibleThing)
        XCTAssertEqual(fooBarResult.int, 1)
        XCTAssertEqual(defaultResult.int, 2)
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
        XCTAssertEqual(defaultResult2, "baz")
    }

    // Verify tests

    func test_verifyNever_succeedsWhenMockIsNeverInvoked() {
        let mockStringIntToString = when("foo", 42).then("bar")
        _ = TestClass(stringIntToString: unbox(mockStringIntToString))
        
        verifyNever(mockStringIntToString)
    }
}
