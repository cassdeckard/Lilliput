//: Playground - noun: a place where people can play

import UIKit

class Bar<A, B>: NSObject {

    let myA: A
    let myB: B

    init(a: A, b: B) {
        myA = a
        myB = b
    }

    override var description: String {
        return "Bar(\(myA), \(myB))"
    }
}

class Foo<A> {
    let myA: A

    init(a: A) {
        myA = a
    }

    func getBar<B>(b: B) -> Bar<A, B> {
        return Bar(a: myA, b: b)
    }
}

class BarEater<S, T> {
    typealias FavoriteBar = Bar<S, T>

    func giveBar(_ bar: FavoriteBar) {
        print("yummy \(bar)")
    }
}

class SuperFoo<A, B> : Foo<A> {

    typealias MyBarEater = BarEater<A, B>

    let mybarEater: MyBarEater

    init(a: A, barEater: MyBarEater) {
        mybarEater = barEater
        super.init(a: a)
    }

    override func getBar<B>(b: B) -> Bar<A, B> {
        let bar = Bar(a: myA, b: b)
        mybarEater.giveBar(bar as! MyBarEater.FavoriteBar)
        return bar
    }
}

let sf = SuperFoo(a: "there", barEater: BarEater<String, Int>())
let sfb = sf.getBar(b: 4)
