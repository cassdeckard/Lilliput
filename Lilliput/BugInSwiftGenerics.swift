
import XCTest


class GenericBase<A> {
    func someFunction() {}
}

class GenericSubclass1<A> : GenericBase<A> {}

class GenericSubclass2<A> : GenericSubclass1<A> {}


class Wrapper<A> {
    typealias GenericBaseA = GenericBase<A>

    func getGenericClass<ClassType: GenericBaseA>() -> ClassType {
        return ClassType()
    }

    func callSomeFunction<ClassType: GenericBaseA>(obj: ClassType) -> () {
        obj.someFunction()
    }

    func getSomeFunction<ClassType: GenericBaseA>(obj: ClassType) -> () -> () {
        return obj.someFunction
    }
}

func getGenericClass<A, ClassType: GenericBase<A>>() -> ClassType {
    return ClassType()
}

func callSomeFunction<A, ClassType: GenericBase<A>>(obj: ClassType) {
    obj.someFunction()
}

func getSomeFunction<A, ClassType: GenericBase<A>>(obj: ClassType) -> () -> () {
    return obj.someFunction
}


class BugInSwiftGenerics: XCTestCase {
    func testEachGenericSubclassCanBeInitializedWithNoArguments() {
        let base = GenericBase<Int>()
        let sub1 = GenericSubclass1<Int>()
        let sub2 = GenericSubclass2<Int>()

        XCTAssertNotNil(base)
        XCTAssertNotNil(sub1)
        XCTAssertNotNil(sub2)
    }
}
