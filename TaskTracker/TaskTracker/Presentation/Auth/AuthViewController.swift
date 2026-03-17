import UIKit

final class AuthViewController: UIViewController, AuthView {
    var viewModel: AuthViewModel!

    private var renderedState: AuthViewState?

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()

    private let titleLabel = UILabel()
    private let emailTextField = UITextField()
    private let passwordTextField = UITextField()
    private let errorLabel = UILabel()
    private let primaryButton = UIButton(type: .system)
    private let switchModeButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        setupActions()
        setupKeyboardObservers()
        viewModel.onAppear()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func render(_ state: AuthViewState) {
        renderedState = state

        emailTextField.text = state.email
        passwordTextField.text = state.password
        primaryButton.isEnabled = state.isPrimaryButtonEnabled

        switch state.mode {
        case .login:
            titleLabel.text = "Вход"
            primaryButton.setTitle("Войти", for: .normal)
            switchModeButton.setTitle("Нет аккаунта? Зарегистрироваться", for: .normal)

        case .register:
            titleLabel.text = "Регистрация"
            primaryButton.setTitle("Зарегистрироваться", for: .normal)
            switchModeButton.setTitle("Уже есть аккаунт? Войти", for: .normal)
        }

        switch state.screen {
        case .initial:
            errorLabel.isHidden = true
            errorLabel.text = nil
            activityIndicator.stopAnimating()

        case .loading:
            errorLabel.isHidden = true
            errorLabel.text = nil
            activityIndicator.startAnimating()
            primaryButton.isEnabled = false

        case .content:
            errorLabel.isHidden = true
            errorLabel.text = nil
            activityIndicator.stopAnimating()

        case .empty(let message):
            errorLabel.isHidden = false
            errorLabel.text = message
            activityIndicator.stopAnimating()

        case .error(let message):
            errorLabel.isHidden = false
            errorLabel.text = message
            activityIndicator.stopAnimating()
        }
    }
}

private extension AuthViewController {
    func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Авторизация"

        stackView.axis = .vertical
        stackView.spacing = 12

        titleLabel.font = .boldSystemFont(ofSize: 28)
        titleLabel.textAlignment = .center

        emailTextField.placeholder = "Email"
        emailTextField.borderStyle = .roundedRect
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        emailTextField.returnKeyType = .next
        emailTextField.delegate = self
        emailTextField.accessibilityIdentifier = "auth.email"

        passwordTextField.placeholder = "Пароль"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true
        passwordTextField.autocapitalizationType = .none
        passwordTextField.autocorrectionType = .no
        passwordTextField.returnKeyType = .done
        passwordTextField.delegate = self
        passwordTextField.accessibilityIdentifier = "auth.password"

        errorLabel.font = .systemFont(ofSize: 14)
        errorLabel.textColor = .systemRed
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true

        primaryButton.configuration = .filled()
        primaryButton.accessibilityIdentifier = "auth.primary"

        switchModeButton.titleLabel?.font = .systemFont(ofSize: 14)
        switchModeButton.accessibilityIdentifier = "auth.switchMode"

        activityIndicator.hidesWhenStopped = true

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)

        [
            titleLabel,
            emailTextField,
            passwordTextField,
            errorLabel,
            primaryButton,
            switchModeButton,
            activityIndicator
        ].forEach { stackView.addArrangedSubview($0) }
    }

    func setupLayout() {
        [scrollView, contentView, stackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),

            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.frameLayoutGuide.heightAnchor),

            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -20),

            emailTextField.heightAnchor.constraint(equalToConstant: 44),
            passwordTextField.heightAnchor.constraint(equalToConstant: 44),
            primaryButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }

    func setupActions() {
        emailTextField.addTarget(self, action: #selector(emailChanged), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(passwordChanged), for: .editingChanged)
        primaryButton.addTarget(self, action: #selector(primaryTapped), for: .touchUpInside)
        switchModeButton.addTarget(self, action: #selector(switchModeTapped), for: .touchUpInside)

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
        viewModel.didChangeEmail(emailTextField.text ?? "")
    }

    @objc func passwordChanged() {
        viewModel.didChangePassword(passwordTextField.text ?? "")
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

        scrollView.contentInset.bottom = intersection.height
        scrollView.verticalScrollIndicatorInsets.bottom = intersection.height
    }
}

extension AuthViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField === passwordTextField {
            textField.resignFirstResponder()
            primaryTapped()
        }
        return true
    }
}
