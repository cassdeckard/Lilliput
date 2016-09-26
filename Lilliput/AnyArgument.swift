import Foundation

class AnyArgument<T> {}

func any<T>(_ t: T.Type) -> AnyArgument<T> {
    return AnyArgument<T>()
}
