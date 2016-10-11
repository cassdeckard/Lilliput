//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

prefix operator *

protocol DefaultConstructible {
    init()
}

extension String: DefaultConstructible {}

class Mock<A1, R> {
    typealias Binding = (matcher: AnyMatcherType<A1>, result: R)
    var bindings = [Binding]()
    var defaultReturn: R?

    private func match(_ a1: A1) -> R? {
        return bindings.filter {
            $0.matcher.matches(a1)
        }.map {
            $0.result
        }.first ?? defaultReturn
    }

    internal func `else`(_ r: R) -> Mock {
        defaultReturn = r
        return self
    }

    static prefix func * (mock: Mock) -> (A1) -> R? {
        return mock.match
    }
}

extension Mock where R: DefaultConstructible {
    func elseDefault() {
        defaultReturn = R()
    }
}

extension Mock where A1: Equatable {
    func when(_ a1: A1) -> BoundArgumentMatcherWithTarget<A1, R> {
        return BoundArgumentMatcherWithTarget(a1, target: self)
    }
}

extension Mock {
    func when(_ closure: @escaping ClosureMatcherWithTarget<A1, R>.Closure) -> ClosureMatcherWithTarget<A1, R> {
        return ClosureMatcherWithTarget(closure, target: self)
    }

    func when<M: Matcher>(_ m: M) -> AnyMatcherTypeWithTarget<A1, R> where M.Arg1 == A1 {
        return AnyMatcherTypeWithTarget(m, target: self)
    }
}

//=========================================

class AnyMatcherType<A1>: Matcher {
    private let _match: AnyMatcherType.Closure

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

class AnyMatcherTypeWithTarget<A1, R>: AnyMatcherType<A1>, MatcherWithTarget {
    internal var target: Mock<A1, R>

    typealias Return = R

    init<M: Matcher>(_ matcher: M, target: Mock<A1, R>) where M.Arg1 == Arg1 {
        self.target = target
        super.init(matcher)
    }
}


//=========================================

protocol Matcher {
    associatedtype Arg1

    func matches(_ a1: Arg1) -> Bool
}

extension Matcher {
    typealias Closure = (Arg1) -> Bool
}

extension Matcher {
    internal func then<R>(_ r: R) -> Mock<Arg1, R> {
        let mock = Mock<Arg1, R>()
        mock.bindings.append((matcher: AnyMatcherType(self), result: r))
        return mock
    }
}

protocol MatcherWithTarget: Matcher {
    associatedtype Return

    var target: Mock<Arg1, Return> { get }
}

extension MatcherWithTarget {
    internal func then(_ r: Return) -> Mock<Arg1, Return> {
        let binding = (matcher: AnyMatcherType(self), result: r)
        target.bindings.append(binding)
        return target
    }
}


//=========================================

class BoundArgumentMatcher<A1: Equatable> {
    let a1: A1

    init(_ a1: A1) {
        self.a1 = a1
    }
}

extension BoundArgumentMatcher: Matcher {
    typealias Arg1 = A1

    internal func matches(_ a1: A1) -> Bool {
        return self.a1 == a1
    }
}

class BoundArgumentMatcherWithTarget<A1: Equatable, R>: BoundArgumentMatcher<A1>, MatcherWithTarget {
    let target: Mock<A1, R>

    init(_ a1: A1, target: Mock<A1, R>) {
        self.target = target
        super.init(a1)
    }
}

//=========================================

class ClosureMatcher<A1> {
    let closure: ClosureMatcher.Closure

    init(_ closure: @escaping ClosureMatcher.Closure) {
        self.closure = closure
    }
}

extension ClosureMatcher: Matcher {
    typealias Arg1 = A1

    internal func matches(_ a1: A1) -> Bool {
        return closure(a1)
    }
}

class ClosureMatcherWithTarget<A1, R>: ClosureMatcher<A1>, MatcherWithTarget {
    let target: Mock<A1, R>

    init(_ closure: @escaping ClosureMatcherWithTarget.Closure, target: Mock<A1, R>) {
        self.target = target
        super.init(closure)
    }
}

//=========================================

class AnyMatcher<A1> {
}

extension AnyMatcher: Matcher {
    typealias Arg1 = A1

    internal func matches(_ a1: A1) -> Bool {
        return true
    }
}

func any<T>(_ ttype: T.Type) -> AnyMatcher<T> {
    return AnyMatcher<T>()
}

//=========================================

func when<A1>(_ closure: @escaping ClosureMatcher<A1>.Closure) -> ClosureMatcher<A1> {
    return ClosureMatcher(closure)
}

func when<A1>(_ a1: A1) -> BoundArgumentMatcher<A1> {
    return BoundArgumentMatcher(a1)
}

func when<M: Matcher, A1>(_ m: M) -> AnyMatcherType<A1> where M.Arg1 == A1 {
    return AnyMatcherType<A1>(m)
}

//=========================================

var mock1 = when(2).then("bar").else("NO DICE")
var mock1Func = *mock1
mock1Func(1)
mock1Func(2)

mock1.when(3).then("oooooooyeah")

mock1Func(3)

mock1.when{ $0 % 7 == 0 }.then("totes divisible by 7 yo")

mock1Func(7)
mock1Func(8)

var mock2 = when{ $0 < 3 }.then("foo")
var mock2Func = *mock2
mock2Func(2)
mock2Func(3)

mock2.elseDefault()
mock2Func(3)

mock2.when(6).then("sweet sassy molassey").else("NOPERS")

mock2Func(6)

mock2.when{ $0 % 9 == 0 }.then("NOINE!")

mock2Func(0)   // NOTE: when multiple matchers match, the first wins
mock2Func(18)
mock2Func(8)

mock2.when(any(Int.self)).then("Any int is fine!")
mock2Func(30930)

var mock3 = when(any(Int.self)).then(3)
var mock3Func = *mock3
mock3Func(-1)
mock3Func(65535)


// TODO: verify times

// TODO: multiple arguments

