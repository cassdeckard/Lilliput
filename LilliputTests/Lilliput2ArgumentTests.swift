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
        let aMock = mock(String.self, String.self).returning(String)
        XCTAssertEqual(unbox(aMock)("foo", "bar"), "")
    }

    func test_mockBuilder_withNonDefaultConstructibleReturn_createsMockWithNoMatchers() {
        let aMock = mock(String.self, Int.self).returning(Int).orElse(3)
        XCTAssertEqual(unbox(aMock)("foo", 2), 3)
    }

    func test_mockCreatedWithMockBuilder_canAddMatchers() {
        let aMock = mock(String.self, Int.self).returning(String)
        aMock.when("Foo", 2).then("HI")
        let result = unbox(aMock)("Foo", 2)
        XCTAssertEqual(result, "HI")
    }

    func test_mockCreatedWithMockBuilder_withNonDefaultConstructibleReturn_canAddMatchers() {
        let aMock = mock(String.self, Int.self).returning(Int).orElse(13)
        aMock.when("Foo", 2).then(14)
        let result = unbox(aMock)("Foo", 2)
        XCTAssertEqual(result, 14)
    }

    func test_any() {
        let mockStringIntToString = when("foo", 2).then("bar")
        mockStringIntToString.when("foo", any(Int)).then("baz")
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
        let captureString = capture(String)
        let mockStringsToInt = mock(String.self, String.self).returning(Int).orElse(0)
        mockStringsToInt.when(captureString, "bar").then(12)

        let result = unbox(mockStringsToInt)("foo", "bar")

        verifyAtLeastOnce(mockStringsToInt)
        XCTAssertEqual(result, 12)
        XCTAssertNotNil(captureString.capturedArgument)
        if let string = captureString.capturedArgument {
            XCTAssertEqual(string, "foo")
        }
    }

    func test_captureArgument_isOnlyCaptured_whenOtherArgumentsMatch() {
        let captureString = capture(String)
        let mockStringsToInt = mock(String.self, String.self).returning(Int).orElse(0)
        mockStringsToInt.when(captureString, "bar").then(12)

        let result = unbox(mockStringsToInt)("foo", "BAR")

        verifyAtLeastOnce(mockStringsToInt)
        XCTAssertEqual(result, 0)
        XCTAssertNil(captureString.capturedArgument)
    }

    // ReturnType tests

    func test_returnType_canBeNotDefaultConstructible_ifDefaultIsProvided() {
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
        XCTAssertEqual(defaultResult2, "baz")
    }

    // Verify tests

    func test_verifyNever_succeedsWhenMockIsNeverInvoked() {
        let mockStringIntToString = when("foo", 42).then("bar")
        _ = TestClass(stringIntToString: unbox(mockStringIntToString))
        
        verifyNever(mockStringIntToString)
    }
}
