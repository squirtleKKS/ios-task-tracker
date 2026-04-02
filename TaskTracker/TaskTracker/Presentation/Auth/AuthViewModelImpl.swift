import Foundation

@MainActor
final class AuthViewModelImpl: AuthViewModel {
    var onStateChange: ((AuthViewState) -> Void)?

    private let router: AuthRouter
    private let authService: AuthService

    private(set) var state = AuthViewState(
        screen: .initial,
        email: "",
        password: "",
        isPrimaryButtonEnabled: false,
        mode: .login
    ) {
        didSet {
            onStateChange?(state)
        }
    }

    init(
        router: AuthRouter,
        authService: AuthService
    ) {
        self.router = router
        self.authService = authService
    }

    func onAppear() {
        updateState {
            $0.screen = .content(AuthContent())
        }
    }

    func didChangeEmail(_ email: String) {
        updateState {
            $0.email = email
            updateButtonState(&$0)
            clearErrorIfNeeded(&$0)
        }
    }

    func didChangePassword(_ password: String) {
        updateState {
            $0.password = password
            updateButtonState(&$0)
            clearErrorIfNeeded(&$0)
        }
    }

    func didTapSwitchMode() {
        updateState {
            $0.mode = ($0.mode == .login) ? .register : .login
            $0.email = ""
            $0.password = ""
            $0.isPrimaryButtonEnabled = false
            $0.screen = .content(AuthContent())
        }
    }

    func didTapLogin() {
        guard state.mode == .login else { return }
        submitLogin()
    }

    func didTapRegister() {
        guard state.mode == .register else { return }
        submitRegister()
    }

    private func submitLogin() {
        let email = normalized(state.email)
        let password = normalized(state.password)

        guard validateFields(email: email, password: password) else { return }

        updateState {
            $0.screen = .loading
            $0.isPrimaryButtonEnabled = false
        }

        Task { [weak self] in
            guard let self else { return }

            do {
                _ = try await authService.login(email: email, password: password)

                updateState {
                    $0.screen = .content(AuthContent())
                    self.updateButtonState(&$0)
                }
                router.openFeatures()
            } catch {
                updateState {
                    $0.screen = .error(message: self.errorMessage(from: error))
                    self.updateButtonState(&$0)
                }
            }
        }
    }

    private func submitRegister() {
        let email = normalized(state.email)
        let password = normalized(state.password)

        guard validateFields(email: email, password: password) else { return }

        updateState {
            $0.screen = .loading
            $0.isPrimaryButtonEnabled = false
        }

        Task { [weak self] in
            guard let self else { return }

            do {
                _ = try await authService.register(email: email, password: password)

                updateState {
                    $0.screen = .content(AuthContent())
                    self.updateButtonState(&$0)
                }
                router.openFeatures()
            } catch {
                updateState {
                    $0.screen = .error(message: self.errorMessage(from: error))
                    self.updateButtonState(&$0)
                }
            }
        }
    }

    private func validateFields(email: String, password: String) -> Bool {
        guard !email.isEmpty, !password.isEmpty else {
            updateState {
                $0.screen = .error(message: "Заполни email и пароль")
            }
            return false
        }
        return true
    }

    private func updateButtonState(_ state: inout AuthViewState) {
        let email = normalized(state.email)
        let password = normalized(state.password)
        state.isPrimaryButtonEnabled = !email.isEmpty && !password.isEmpty
    }

    private func clearErrorIfNeeded(_ state: inout AuthViewState) {
        if case .error = state.screen {
            state.screen = .content(AuthContent())
        }
    }

    private func normalized(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func errorMessage(from error: Error) -> String {
        if let localized = error as? LocalizedError,
           let description = localized.errorDescription {
            return description
        }
        return "Что-то пошло не так"
    }

    private func updateState(_ mutate: (inout AuthViewState) -> Void) {
        var newState = state
        mutate(&newState)
        state = newState
    }
}
