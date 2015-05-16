# Lilliput
An experiment in adding mock support to Swift

```swift
 // Say you have a function you would like to mock
 func realFunction(inString: String) -> String {
     return inString.toLower()
 }

 // Create a mock for it
 let mockStringFilter = when("foo").then("bar")

 // You can now use it in place of a function with the same signature
 let testObject = TestClass(stringFilter: unbox(mockStringFilter))

 // Exercise the test object in a way that will use the mocked function
 let result = testObject.useStringFilter("foo")

 // Verify that the mock function was called at least once
 verifyAtLeastOnce(mockStringFilter)

 // And you get the expected result
 XCTAssertEqual(result, "bar")

 // If the return type has no default init, you supply a default with 'orElse'
 let mockStringToInt = when("foo").then(1).orElse(2)
 let testObject = TestClass(stringToInt: unbox(mockStringToInt))

 let fooResult = testObject.useStringToInt("foo")
 let defaultResult = testObject.useStringToInt("NOT FOO")

 // The supplied default will be used if the argument doesn't match any 'when'
 verifyAtLeastOnce(mockStringToInt)
 XCTAssertEqual(fooResult, 1)
 XCTAssertEqual(defaultResult, 2)
```
