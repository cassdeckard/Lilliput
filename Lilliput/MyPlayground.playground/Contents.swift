//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

prefix operator *

class Mock<M: Matcher, R> {
    typealias Binding = (matcher: M, result: R)
    var bindings = [Binding]()

    private func match(_ a1: M.Arg1) -> R? {
        return bindings.filter {
            $0.matcher.matches(a1)
        }.map {
            $0.result
        }.first
    }

    static prefix func * (mock: Mock) -> (M.Arg1) -> R? {
        return mock.match
    }
}

protocol Matcher {
    associatedtype Arg1

    func matches(_ a1: Arg1) -> Bool
}

extension Matcher {
    internal func then<R>(_ r: R) -> Mock<Self, R> {
        let mock = Mock<Self, R>()
        mock.bindings.append((matcher: self, result: r))
        return mock
    }
}

//=========================================

struct BoundArgumentMatcher<A1: Equatable> {
    let a1: A1
}

extension BoundArgumentMatcher: Matcher {
    typealias Arg1 = A1

    internal func matches(_ a1: A1) -> Bool {
        return self.a1 == a1
    }
}


//=========================================

struct ClosureMatcher<A1> {
    let closure: (A1) -> Bool
}

extension ClosureMatcher: Matcher {
    typealias Arg1 = A1

    internal func matches(_ a1: A1) -> Bool {
        return closure(a1)
    }
}

//=========================================

func when<A1>(_ closure: @escaping (A1) -> Bool) -> ClosureMatcher<A1> {
    return ClosureMatcher(closure: closure)
}

func when<A1>(_ a1: A1) -> BoundArgumentMatcher<A1> {
    return BoundArgumentMatcher(a1: a1)
}

//=========================================

var mock1 = when(2).then("bar")
var mock1Func = *mock1
mock1Func(1)
mock1Func(2)

mock1.bindings.append((matcher: BoundArgumentMatcher(a1: 3), result: "aowow"))

mock1Func(3)

var mock2 = when{ $0 < 3 }.then("foo")
var mock2Func = *mock2
mock2Func(2)
mock2Func(3)