import XCTest

class NonDefaultConstructibleThing {
    let int: Int

    init(_ int: Int) {
        self.int = int
    }
}

class Lilliput1ArgumentTests: XCTestCase {

    class TestClass {
        typealias StringFilter = (String) -> (String)
        typealias StringToInt = (String) -> (Int)
        typealias StringToNonDefaultConstructibleThing = (String) -> (NonDefaultConstructibleThing)

        var stringFilter : StringFilter!
        var stringToInt : StringToInt!
        var stringToNonDefaultConstructibleThing : StringToNonDefaultConstructibleThing!

        init(stringFilter : @escaping StringFilter) {
            self.stringFilter = stringFilter
        }

        init(stringToInt : @escaping StringToInt) {
            self.stringToInt = stringToInt
        }

        init(stringToNonDefaultConstructibleThing : @escaping StringToNonDefaultConstructibleThing) {
            self.stringToNonDefaultConstructibleThing = stringToNonDefaultConstructibleThing
        }

        func useStringFilter(_ inString: String) -> String {
            return self.stringFilter(inString)
        }

        func useStringToInt(_ inString: String) -> Int {
            return self.stringToInt(inString)
        }

        func useStringToNonDefaultConstructibleThing(_ inString: String) -> NonDefaultConstructibleThing {
            return self.stringToNonDefaultConstructibleThing(inString)
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

    func test_mockBuilder_createsMockWithNoMatchers() {
        let aMock = mock(String.self).returning(String.self)
        XCTAssertEqual(unbox(aMock)("foo"), "")
    }

    func test_mockBuilder_withNonDefaultConstructibleReturn_createsMockWithNoMatchers() {
        let aMock = mock(String.self).returning(NonDefaultConstructibleThing.self).orElse(NonDefaultConstructibleThing(24))
        XCTAssertEqual(unbox(aMock)("foo").int, 24)
    }

    func test_mockCreatedWithMockBuilder_canAddMatchers() {
        let aMock = mock(String.self).returning(String.self)
        aMock.when("Foo").then("HI")
        let result = unbox(aMock)("Foo")
        XCTAssertEqual(result, "HI")
    }

    func test_mockCreatedWithMockBuilder_withNonDefaultConstructibleReturn_canAddMatchers() {
        let aMock = mock(Int.self).returning(NonDefaultConstructibleThing.self).orElse(NonDefaultConstructibleThing(13))
        aMock.when(2).then(NonDefaultConstructibleThing(14))

        let result = unbox(aMock)(2)
        XCTAssertEqual(result.int, 14)
    }

    func test_any() {
        let mockStringFilter = mock(String.self).returning(String.self)
        mockStringFilter.when("foo").then("bar")
        mockStringFilter.when(any(String.self)).then("baz")
        let testObject = TestClass(stringFilter: unbox(mockStringFilter))

        let result1 = testObject.useStringFilter("foo")
        let resultAny = testObject.useStringFilter("NOT FOO")

        verifyAtLeastOnce(mockStringFilter)
        XCTAssertEqual(result1, "bar")
        XCTAssertEqual(resultAny, "baz")
    }

    // Capturing

    func test_capture() {
        let captureString = capture(String.self)
        let mockStringToInt = mock(String.self).returning(Int.self)
        mockStringToInt.when(captureString).then(12)

        let result = unbox(mockStringToInt)("foo")

        verifyAtLeastOnce(mockStringToInt)
        XCTAssertEqual(result, 12)
        XCTAssertNotNil(*captureString)
        if let string = *captureString {
            XCTAssertEqual(string, "foo")
        }
    }

    // ReturnType tests

    func test_returnType_canBeNotDefaultConstructible_ifDefaultIsProvided() {
        let mockStringToNonDefaultConstructibleThing = when("foo").then(NonDefaultConstructibleThing(1)).orElse(NonDefaultConstructibleThing(2))
        let testObject = TestClass(stringToNonDefaultConstructibleThing: unbox(mockStringToNonDefaultConstructibleThing))

        let fooResult = testObject.useStringToNonDefaultConstructibleThing("foo")
        let defaultResult = testObject.useStringToNonDefaultConstructibleThing("NOT FOO")

        verifyAtLeastOnce(mockStringToNonDefaultConstructibleThing)
        XCTAssertEqual(fooResult.int, 1)
        XCTAssertEqual(defaultResult.int, 2)
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
        let _ = TestClass(stringFilter: unbox(mockStringFilter))

        verifyNever(mockStringFilter)
    }
}
