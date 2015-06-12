import Foundation

class NoArgument: Equatable { }

func ==(lhs: NoArgument, rhs: NoArgument) -> Bool {
    return true
}