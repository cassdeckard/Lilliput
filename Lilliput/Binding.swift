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
    associatedtype Matcher
    
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

//class NewBinding<A, M: MatcherType, R>: Binding<A, M> where M.ArgumentType == A {
//    typealias TargetType = MockFunction<NewBinding, R>
//    let target: TargetType
//    
//    init(testCase: XCTestCase, target: TargetType, _ argA: A) {
//        self.target = target
//        super.init(testCase: testCase, matcher: argA)
//    }
//    
//    @discardableResult
//    override func then<R>(_ returnValue: R) -> BoundResult<NewBinding, R> {
//        let boundResult: BoundResult<NewBinding, R> = BoundResult(binding: self, to: returnValue)
//        target.addBoundResult(boundResult as! TargetType.BoundResultType) // Warning is bogus, ignore
//        return boundResult
//    }
//}
