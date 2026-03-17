import Foundation

enum AuthMode {
    case login
    case register
}

struct AuthViewState {
    var screen: LoadableState<AuthContent>
    var email: String
    var password: String
    var isPrimaryButtonEnabled: Bool
    var mode: AuthMode
}

struct AuthContent: Equatable {
    init() {}
}
