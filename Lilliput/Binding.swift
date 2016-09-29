import Foundation
import XCTest

protocol MatcherType {
    associatedtype ArgumentType
    
    func matches(_ argument: ArgumentType) -> Bool
}

class EqualsMatcher<T: Equatable> : MatcherType {
    typealias ArgumentType = T
    
    let matchingArgument: ArgumentType
    
    init(_ argument: ArgumentType) {
        matchingArgument = argument
    }
    
    internal func matches(_ argument: ArgumentType) -> Bool {
        return argument == matchingArgument
    }
}

protocol BindingType {
    associatedtype ArgumentType
    
    var testCase: XCTestCase { get }
    
    func matches(_ argA: ArgumentType) -> Bool
}

class Binding<A, M: MatcherType>: BindingType where M.ArgumentType == A {
    typealias ArgumentType = A
    typealias Matcher = M
    
    let testCase: XCTestCase
    let matcher: Matcher
    
    init(testCase: XCTestCase, matcher: Matcher) {
        self.testCase = testCase
        self.matcher = matcher
    }
    
    func then<R>(_ returnValue: R) -> BoundResult<Binding, R> {
        return BoundResult(binding: self, to: returnValue)
    }
    
    func matches(_ argA: Matcher.ArgumentType) -> Bool {
        return matcher.matches(argA)
    }
}

extension Binding where A: Equatable, M: EqualsMatcher<A> {
    static func create(testCase: XCTestCase, _ argA: A) -> Binding<A, M> {
        return Binding(testCase: testCase, matcher: EqualsMatcher<A>(argA) as! M)
    }
}

class NewBinding<A, M: MatcherType, MF: MockFunctionType>: Binding<A, M> where M.ArgumentType == A {
    typealias R = MF.ResultType
    let target: MF
    
    init(testCase: XCTestCase, target: MF, matcher: Matcher) {
        self.target = target
        super.init(testCase: testCase, matcher: matcher)
    }
    
    override func then<R>(_ returnValue: R) -> BoundResult<Binding<A, M>, R> {
        let boundResult: MF.BoundResultType = BoundResult(binding: self, to: returnValue) as! MF.BoundResultType
        target.addBoundResult(boundResult) // Warning is bogus, ignore
        return boundResult as! BoundResult<Binding<A, M>, R>
    }
//
//    @discardableResult
//    override func then<R>(_ returnValue: R) -> BoundResult<NewBinding, R> {
//        let boundResult: BoundResult<NewBinding, R> = BoundResult(binding: self, to: returnValue)
//        target.addBoundResult(boundResult as! TargetType.BoundResultType) // Warning is bogus, ignore
//        return boundResult
//    }
}

extension NewBinding where A: Equatable, M: EqualsMatcher<A> {
    static func create(testCase: XCTestCase, target: MF, _ argA: A) -> NewBinding<A, M, MF> {
        return NewBinding(testCase: testCase, target: target, matcher: EqualsMatcher<A>(argA) as! M)
    }
}
