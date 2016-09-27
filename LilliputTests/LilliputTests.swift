import XCTest
@testable import Lilliput

class LilliputTests: XCTestCase {
    func test_returnsExpectedValueWhenInputMatches() {
        let mock_String👉String = when("foo").then("bar").else("baz")
        
        let callable: (String) -> (String) = mock_String👉String.unbox()
        
        XCTAssertEqual(callable("foo"), "bar")
    }
    
    func test_returnsDefaultValueWhenInputDoesNotMatch() {
        let mock_String👉String = when("foo").then("bar").else("baz")
        
        let callable: (String) -> (String) = mock_String👉String.unbox()
        
        XCTAssertEqual(callable("FOUX"), "baz")
    }
}
