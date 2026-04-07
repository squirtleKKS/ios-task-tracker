import Foundation

@MainActor
protocol AuthViewModel: AnyObject {
    var state: AuthViewState { get }
    var onStateChange: ((AuthViewState) -> Void)? { get set }

    func onAppear()
    func didChangeEmail(_ email: String)
    func didChangePassword(_ password: String)
    func didTapLogin()
    func didTapRegister()
    func didTapSwitchMode()
}
