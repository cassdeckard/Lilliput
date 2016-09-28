//: Playground - noun: a place where people can play

import UIKit

struct Bar<A, B> {
    let a: A
    let b: B

    var description: String {
        return "Bar(\(a), \(b))"
    }
}

class BarEater<A, B> {
    typealias FavoriteBar = Bar<A, B>

    func giveBar(_ bar: FavoriteBar) {
        print("yummy \(bar)")
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

class SuperFoo<A, B> : Foo<A> {
    typealias MyBarEater = BarEater<A, B>

    let mybarEater: MyBarEater

    init(a: A, barEater: MyBarEater) {
        mybarEater = barEater
        super.init(a: a)
    }

    override func getBar<B>(b: B) -> Bar<A, B> {
        let bar = Bar(a: myA, b: b)
        mybarEater.giveBar(bar as! MyBarEater.FavoriteBar) // "Cast from 'Bar<A, B>' to unrelated type 'Bar<A, B>' always fails"
        return bar
    }
}

let sf = SuperFoo(a: "there", barEater: BarEater<String, Int>())
let sfb = sf.getBar(b: 4) // Cast does not fail because "yummy Bar<String, Int>(a: "there", b: 4)" is printed
