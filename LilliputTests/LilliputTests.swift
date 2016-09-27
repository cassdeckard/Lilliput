import XCTest
@testable import Lilliput

class LilliputTests: XCTestCase {
    func test_returnsExpectedValueWhenInputMatches() {
        let mock_String👉String = when("foo").then("bar")
        
        let callable: (String) -> (String) = mock_String👉String.unbox()
        
        XCTAssertEqual(callable("foo"), "bar")
    }
}
