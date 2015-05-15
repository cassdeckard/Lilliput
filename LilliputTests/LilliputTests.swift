import Cocoa
import XCTest

protocol DefaultConstructable {
    init()
}

extension String: DefaultConstructable {}

class MockFunction<T: Hashable, ReturnType: DefaultConstructable> {
    typealias Signature = (T) -> ReturnType
    typealias TBinding = Binding<T>

    var bindings: [TBinding : ReturnType] = [:]
    var invocationCount = 0

    init(binding: Binding<T>, returnValue: ReturnType) {
        bindings[binding] = returnValue
    }

    func unbox() -> Signature {
        return {
            (arg: T) in
            self.invocationCount++
            return ReturnType()
        }
    }
}

class Binding<T where T: Hashable, T: Equatable> {
    let boundArgument: T

    init(_ arg: T) {
        boundArgument = arg
    }

    func then<ReturnType>(returnValue: ReturnType) -> MockFunction<T, ReturnType> {
        return MockFunction<T, ReturnType>(binding: self, returnValue: returnValue)
    }
}

extension Binding: Hashable {
    var hashValue: Int {
        get {
            return boundArgument.hashValue
        }
    }
}

func ==<T where T: Hashable, T: Equatable>(lhs: Binding<T>, rhs: Binding<T>) -> Bool {
    return lhs.boundArgument == rhs.boundArgument
}
extension Binding: Equatable {}

func when<T: Hashable>(arg: T) -> Binding<T> {
    return Binding(arg)
}

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
        let mockStringFilter = when("foo").then("bar")

        let testObject = TestClass(stringFilter: mockStringFilter.unbox())

        let result = testObject.useStringFilter("foo")

        XCTAssertEqual(mockStringFilter.invocationCount, 1)
    }
}
