import Foundation

struct AuthViewState: Equatable {
    var screen: LoadableState<AuthContent>
    var email: String
    var password: String
    var isLoginEnabled: Bool
}

struct AuthContent: Equatable {
    init() {}
}
