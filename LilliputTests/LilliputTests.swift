import Cocoa
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
        let mockStringFilter = MockFunc<String, String>()
        var capturedArg : String?
        let expectedResult = "result"
        when(mockStringFilter) {
            (arg: String) in
            capturedArg = arg
            return expectedResult
        }

        let passedArg = "argument"
        let result = (*mockStringFilter)(passedArg)

        verifyAtLeastOnce(mockStringFilter)
        XCTAssertEqual(capturedArg!, passedArg)
        XCTAssertEqual(result, expectedResult)
    }

    func testThatWeCanInjectTheMock() {
        let mockStringFilter = MockFunc<String, String>()
        var capturedArg : String?
        let expectedResult = "aResult"
        when(mockStringFilter) {
            (arg: String) in
            capturedArg = arg
            return expectedResult
        }

        let passedArg = "anArgument"
        let testClass = TestClass(stringFilter: *mockStringFilter)

        let result = testClass.useStringFilter(passedArg)

        verifyAtLeastOnce(mockStringFilter)
        XCTAssertEqual(capturedArg!, passedArg)
        XCTAssertEqual(result, expectedResult)
    }

    func testMockConstructorThatUsesRealFunction() {
        func realFunction(String) -> String { return "" }

        let mockFunction = mock(realFunction)

        XCTAssertTrue(mockFunction is MockFunc<String, String>)
    }

    func testThatWeCanMockVoidFunctions_andCallThemWithoutNeedingToCallWhenFirst() {
        func realFunction(String) -> () { return }

        let mockFunction = mock(realFunction)

        (*mockFunction)("test")

        verifyAtLeastOnce(mockFunction)
        XCTAssertEqual(mockFunction.capturedArguments.first!, "test")
    }

    func testThatWhenDoesWorkForVoidFunctions() {
        func realFunction(Int) -> () { return }

        let mockFunction = mock(realFunction)
        var capturedArg : Int?
        when(mockFunction) {
            (arg: Int) in
            capturedArg = arg
        }
        (*mockFunction)(13)

        verifyAtLeastOnce(mockFunction)
        XCTAssertEqual(capturedArg!, 13)
    }

    func testThatWeCanMockFunctionsWithTwoParameters() {
        func realFunction(String, Int) -> String { return "" }
        let mockFunction = mock(realFunction)

        var capturedString : String?
        var capturedInt : Int?
        when(mockFunction) {
            (stringArg: String, intArg: Int) in
            capturedString = stringArg
            capturedInt = intArg
            return "foo"
        }

        let result = (*mockFunction)("bar", 42)

        verifyAtLeastOnce(mockFunction)
        XCTAssertEqual(capturedString!, "bar")
        XCTAssertEqual(capturedInt!, 42)
        XCTAssertEqual(result, "foo")
    }
}
