# Lilliput
An experiment in adding mock support to Swift

```swift
// Create a mock for a function
let mockStringFilter = MockFunc<String, String>()

// Capture an argument, and return a result
var capturedArg : String?
let expectedResult = "aResult"
when(mockStringFilter) {
    (arg: String) in
    capturedArg = arg
    return expectedResult
}

// Inject the mock - note the asterisk operator used to "dereference" the underlying mocked function
let testObject = SomeClass(stringFilter: *mockStringFilter)

// Use the mock
let passedArg = "anArgument"
let result = testObject.useStringFilter(passedArg)

// Verify the mocked function was called
verifyAtLeastOnce(mockStringFilter)

// Verify passed arguments and captured results
XCTAssertEqual(capturedArg!, passedArg)
XCTAssertEqual(result, expectedResult)
```
