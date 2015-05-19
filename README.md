# Lilliput
An experiment in adding mock support to Swift

## Basic Usage

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

## Slightly Advanced Usage

```swift
// You can use any(Type) to match any supplied argument
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

// Unfortunately there is currently a limitation where mocks with an any() argument cannot be constructed
// with when() syntax. So you may need to use the "mock builder" syntax to construct a mock with no
// matchers first:
let mockStringFilter = mock(String).returning(String)
mockStringFilter.when(any(String)).then("I got some string!")

// Unfortunately there is currently a limitation in the "mock builder" syntax requiring the use of ".self"
// for the argument types for more than one argument
let mockWithTwoArgs = mock(String.self, Int.self).returning(String)
```
