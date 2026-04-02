import UIKit

final class AuthViewController: UIViewController {

    var viewModel: AuthViewModel!

    private var renderedState: AuthViewState?
    private let contentView = AuthContentView()

    override func loadView() {
        view = contentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Авторизация"

        setupActions()
        setupKeyboardObservers()
        bindViewModel()
        render(viewModel.state)

        viewModel.onAppear()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            self?.render(state)
        }
    }

    private func render(_ state: AuthViewState) {
        renderedState = state

        contentView.emailTextField.text = state.email
        contentView.passwordTextField.text = state.password
        contentView.primaryButton.isEnabled = state.isPrimaryButtonEnabled

        switch state.mode {
        case .login:
            contentView.titleLabel.text = "Вход"
            contentView.primaryButton.setTitle("Войти", for: .normal)
            contentView.switchModeButton.setTitle("Нет аккаунта? Зарегистрироваться", for: .normal)

        case .register:
            contentView.titleLabel.text = "Регистрация"
            contentView.primaryButton.setTitle("Зарегистрироваться", for: .normal)
            contentView.switchModeButton.setTitle("Уже есть аккаунт? Войти", for: .normal)
        }

        switch state.screen {
        case .initial:
            contentView.errorLabel.isHidden = true
            contentView.activityIndicator.stopAnimating()

        case .loading:
            contentView.errorLabel.isHidden = true
            contentView.activityIndicator.startAnimating()
            contentView.primaryButton.isEnabled = false

        case .content:
            contentView.errorLabel.isHidden = true
            contentView.activityIndicator.stopAnimating()

        case .empty(let message):
            contentView.errorLabel.isHidden = false
            contentView.errorLabel.text = message
            contentView.activityIndicator.stopAnimating()

        case .error(let message):
            contentView.errorLabel.isHidden = false
            contentView.errorLabel.text = message
            contentView.activityIndicator.stopAnimating()
        }
    }
}

private extension AuthViewController {

    func setupActions() {
        contentView.emailTextField.addTarget(self, action: #selector(emailChanged), for: .editingChanged)
        contentView.passwordTextField.addTarget(self, action: #selector(passwordChanged), for: .editingChanged)
        contentView.primaryButton.addTarget(self, action: #selector(primaryTapped), for: .touchUpInside)
        contentView.switchModeButton.addTarget(self, action: #selector(switchModeTapped), for: .touchUpInside)

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapOutside))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChangeFrame(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }

    @objc func emailChanged() {
        viewModel.didChangeEmail(contentView.emailTextField.text ?? "")
    }

    @objc func passwordChanged() {
        viewModel.didChangePassword(contentView.passwordTextField.text ?? "")
    }

    @objc func primaryTapped() {
        guard let mode = renderedState?.mode else { return }

        switch mode {
        case .login:
            viewModel.didTapLogin()
        case .register:
            viewModel.didTapRegister()
        }
    }

    @objc func switchModeTapped() {
        viewModel.didTapSwitchMode()
    }

    @objc func handleTapOutside() {
        view.endEditing(true)
    }

    @objc func keyboardWillChangeFrame(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let endFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else { return }

        let keyboardFrameInView = view.convert(endFrame, from: nil)
        let intersection = view.bounds.intersection(keyboardFrameInView)

        contentView.scrollView.contentInset.bottom = intersection.height
        contentView.scrollView.verticalScrollIndicatorInsets.bottom = intersection.height
    }
}
