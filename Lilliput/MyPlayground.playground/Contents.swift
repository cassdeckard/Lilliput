//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

prefix operator *

class Mock<A1, R> {
    typealias Matcher = AnyMatcher<A1>
    typealias Binding = (matcher: AnyMatcher<A1>, result: R)
    var bindings = [Binding]()

    private func match(_ a1: A1) -> R? {
        return bindings.filter {
            $0.matcher.matches(a1)
        }.map {
            $0.result
        }.first
    }

    static prefix func * (mock: Mock) -> (A1) -> R? {
        return mock.match
    }
}

protocol Matcher {
    associatedtype Arg1

    func matches(_ a1: Arg1) -> Bool
}

extension Matcher {
    internal func then<R>(_ r: R) -> Mock<Arg1, R> {
        let mock = Mock<Arg1, R>()
        mock.bindings.append((matcher: AnyMatcher(self), result: r))
        return mock
    }
}

//=========================================

struct AnyMatcher<A1>: Matcher {
    private let _match: (A1) -> Bool

    typealias Arg1 = A1

    init<M: Matcher>(_ matcher: M) where M.Arg1 == Arg1 {
        _match = {
            matcher.matches($0)
        }
    }

    internal func matches(_ a1: A1) -> Bool {
        return _match(a1)
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

mock1.bindings.append((matcher: AnyMatcher(BoundArgumentMatcher(a1: 3)), result: "aowow"))

mock1Func(3)

var mock2 = when{ $0 < 3 }.then("foo")
var mock2Func = *mock2
mock2Func(2)
mock2Func(3)


mock2.bindings.append((matcher: AnyMatcher(BoundArgumentMatcher(a1: 6)), result: "aowow"))

mock2Func(6)
