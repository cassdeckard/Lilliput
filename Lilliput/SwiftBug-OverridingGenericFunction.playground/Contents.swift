//: Playground - noun: a place where people can play

import UIKit

class Foo {
    func getInt() -> Int {
        print("Foo.getInt")
        return 0
    }

    func takeThing<T>(_ thing: T) {
        print("Foo.takeThing")
    }
}

class Bar : Foo {
    override func getInt() -> Int {
        print("Bar.getInt")
        return 1
    }

    // OK
    override func takeThing<T>(_ thing: T) {
        print("Bar.takeThing")

    }
}

class Baz<E> : Foo {

    // OK
    override func getInt() -> Int {
        print("Baz.getInt")
        return 2
    }

    // "Method does not override any method from its superclass"
    override func takeThing<T>(_ thing: T) {
        print("Baz.takeThing")

    }
}

let f = Foo()
f.getInt()
f.takeThing("hi")


let b = Bar()
b.getInt()
b.takeThing("hi")

let z = Baz<Int>()
z.getInt()
z.takeThing("hi")
