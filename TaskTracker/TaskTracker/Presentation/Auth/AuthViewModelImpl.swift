import Foundation

final class AuthViewModelImpl: AuthViewModel {
    private weak var view: AuthView?
    private let router: AuthRouter
    private let authService: AuthService

    private var state = AuthViewState(
        screen: .initial,
        email: "",
        password: "",
        isPrimaryButtonEnabled: false,
        mode: .login
    )

    init(
        view: AuthView,
        router: AuthRouter,
        authService: AuthService
    ) {
        self.view = view
        self.router = router
        self.authService = authService
    }

    func onAppear() {
        state.screen = .content(AuthContent())
        render()
    }

    func didChangeEmail(_ email: String) {
        state.email = email
        updateButtonState()
        clearErrorIfNeeded()
        render()
    }

    func didChangePassword(_ password: String) {
        state.password = password
        updateButtonState()
        clearErrorIfNeeded()
        render()
    }

    func didTapSwitchMode() {
        state.mode = (state.mode == .login) ? .register : .login
        state.email = ""
        state.password = ""
        state.isPrimaryButtonEnabled = false
        state.screen = .content(AuthContent())
        render()
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

        state.screen = .loading
        state.isPrimaryButtonEnabled = false
        render()

        Task { [weak self] in
            guard let self else { return }

            do {
                _ = try await self.authService.login(email: email, password: password)

                await MainActor.run {
                    self.state.screen = .content(AuthContent())
                    self.updateButtonState()
                    self.render()
                    self.router.openFeatures()
                }
            } catch {
                await MainActor.run {
                    self.state.screen = .error(message: self.errorMessage(from: error))
                    self.updateButtonState()
                    self.render()
                }
            }
        }
    }

    private func submitRegister() {
        let email = normalized(state.email)
        let password = normalized(state.password)

        guard validateFields(email: email, password: password) else { return }

        state.screen = .loading
        state.isPrimaryButtonEnabled = false
        render()

        Task { [weak self] in
            guard let self else { return }

            do {
                _ = try await authService.register(email: email, password: password)

                await MainActor.run {
                    self.state.screen = .content(AuthContent())
                    self.updateButtonState()
                    self.render()
                    self.router.openFeatures()
                }
            } catch {
                await MainActor.run {
                    self.state.screen = .error(message: self.errorMessage(from: error))
                    self.updateButtonState()
                    self.render()
                }
            }
        }
    }

    private func validateFields(email: String, password: String) -> Bool {
        guard !email.isEmpty, !password.isEmpty else {
            state.screen = .error(message: "Заполни email и пароль")
            render()
            return false
        }
        return true
    }

    private func updateButtonState() {
        let email = normalized(state.email)
        let password = normalized(state.password)
        state.isPrimaryButtonEnabled = !email.isEmpty && !password.isEmpty
    }

    private func clearErrorIfNeeded() {
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

    private func render() {
        view?.render(state)
    }
}
