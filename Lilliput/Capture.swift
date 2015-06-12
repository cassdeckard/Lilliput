import Foundation

class Capture<A: Equatable> {
    var _capturedArgument: A?
    var _allowCapture : Bool = false
    var capturedArgument: A? {
        get {
            return _allowCapture ? _capturedArgument : nil
        }
    }
}

func capture<A: Equatable>(type: A.Type) -> Capture<A> {
    return Capture<A>()
}

prefix operator * {}
prefix func *<A: Equatable>(capture: Capture<A>) -> A? {
    return capture.capturedArgument
}