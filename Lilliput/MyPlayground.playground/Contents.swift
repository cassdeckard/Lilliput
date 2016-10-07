//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"


struct Mock<M: Matcher & Hashable, R> {
    var bindings = [M : R]()

    func match(_ a1: M.Arg1) -> R? {
        return bindings.filter {
            $0.key.matches(a1)
        }.map {
            $0.value
        }.first
    }
}

protocol Matcher: Hashable {
    associatedtype Arg1

    func then<R>(_ r: R) -> Mock<Self, R>

    func matches(_ a1: Arg1) -> Bool
}

struct BoundArgumentMatcher<A1: Hashable> {
    let a1: A1
}

extension BoundArgumentMatcher: Equatable {}
func ==<E> (lhs: BoundArgumentMatcher<E>, rhs: BoundArgumentMatcher<E>) -> Bool {
    return false
}

extension BoundArgumentMatcher: Hashable {
    public var hashValue: Int { return a1.hashValue }
}

extension BoundArgumentMatcher: Matcher {
    typealias Arg1 = A1

    internal func then<R>(_ r: R) -> Mock<BoundArgumentMatcher<A1>, R> {
        var mock = Mock<BoundArgumentMatcher<A1>, R>()
        mock.bindings[self] = r
        return mock
    }

    internal func matches(_ a1: A1) -> Bool {
        return self.a1 == a1
    }
}

func when<A1>(_ a1: A1) -> BoundArgumentMatcher<A1> {
    return BoundArgumentMatcher(a1: a1)
}

//=========================================

var mock1 = when(2).then("bar")
mock1.match(1)
mock1.match(2)

