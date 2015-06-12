import Foundation

class AnyArgument<T> {}

func any<T>(t: T.Type) -> AnyArgument<T> {
    return AnyArgument<T>()
}
