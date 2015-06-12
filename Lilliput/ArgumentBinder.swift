import Foundation

class ArgumentBinder<T: Equatable> {
    let arg: T
    init(_ arg: T) {
        self.arg = arg
    }
}

func ==<T: Equatable>(lhs: ArgumentBinder<T>, rhs: T) -> Bool {
    return lhs.arg == rhs
}