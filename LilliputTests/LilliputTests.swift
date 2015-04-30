import Cocoa
import XCTest

class LilliputTests: XCTestCase {
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
}
