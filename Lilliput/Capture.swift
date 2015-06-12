import Foundation

class Capture<A: Equatable> {
    var capturedArgument: A?
}

func capture<A: Equatable>(type: A.Type) -> Capture<A> {
    return Capture<A>()
}