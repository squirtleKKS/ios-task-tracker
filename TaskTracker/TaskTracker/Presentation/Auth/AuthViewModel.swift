import Foundation

protocol AuthViewModel: AnyObject {
    func onAppear()
    func didChangeEmail(_ email: String)
    func didChangePassword(_ password: String)
    func didTapLogin()
    func didTapRegister()
    func didTapSwitchMode()
}
