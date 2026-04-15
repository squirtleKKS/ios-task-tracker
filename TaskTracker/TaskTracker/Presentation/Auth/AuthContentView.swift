import UIKit

final class AuthContentView: UIView {

    var onEmailChanged: ((String) -> Void)?
    var onPasswordChanged: ((String) -> Void)?
    var onPrimaryTap: (() -> Void)?
    var onSwitchModeTap: (() -> Void)?

    private let scrollView = UIScrollView()
    private let containerView = UIView()
    private let formCardView = UIView()
    private let stackView = UIStackView()

    private let headerLabel = UILabel()
    private let emailTextField = DSTextField(title: "Email", placeholder: "Введите email")
    private let passwordTextField = DSTextField(title: "Пароль", placeholder: "Введите пароль")
    private let primaryButton = DSButton(style: .primary)
    private let switchModeButton = DSButton(style: .secondary)
    private let loadingView = DSLoadingView(text: "Проверяем данные...")
    private let messageView = DSMessageView(style: .error, title: "", message: "", actionTitle: nil)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
        setupActions()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func render(_ state: AuthViewState) {
        renderMode(state.mode)
        renderFields(email: state.email, password: state.password)
        renderScreen(state.screen)
        renderActions(state)
    }

    func updateKeyboardInset(_ bottomInset: CGFloat) {
        scrollView.contentInset.bottom = bottomInset
        scrollView.verticalScrollIndicatorInsets.bottom = bottomInset
    }
}

private extension AuthContentView {
    func setupUI() {
        backgroundColor = DesignSystem.Colors.background

        [
            scrollView,
            containerView,
            formCardView,
            stackView,
            headerLabel,
            loadingView,
            messageView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        stackView.axis = .vertical
        stackView.spacing = DesignSystem.Spacing.l

        headerLabel.apply(.title)
        headerLabel.textAlignment = .center

        formCardView.applyCardStyle()

        emailTextField.configureInput(
            keyboardType: .emailAddress,
            returnKeyType: .next,
            autocapitalizationType: .none,
            autocorrectionType: .no,
            accessibilityIdentifier: "auth.email"
        )

        passwordTextField.setSecureEntry(true)
        passwordTextField.configureInput(
            returnKeyType: .done,
            autocapitalizationType: .none,
            autocorrectionType: .no,
            accessibilityIdentifier: "auth.password"
        )

        loadingView.isHidden = true
        messageView.isHidden = true

        addSubview(scrollView)
        addSubview(loadingView)

        scrollView.addSubview(containerView)
        containerView.addSubview(formCardView)
        formCardView.addSubview(stackView)

        [
            headerLabel,
            emailTextField,
            passwordTextField,
            messageView,
            primaryButton,
            switchModeButton
        ].forEach { stackView.addArrangedSubview($0) }
    }

    func setupLayout() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            containerView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            containerView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            containerView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.frameLayoutGuide.heightAnchor),

            formCardView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 96),
            formCardView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: DesignSystem.Spacing.l),
            formCardView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -DesignSystem.Spacing.l),
            formCardView.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -DesignSystem.Spacing.xl),

            stackView.topAnchor.constraint(equalTo: formCardView.topAnchor, constant: DesignSystem.Spacing.xxl),
            stackView.leadingAnchor.constraint(equalTo: formCardView.leadingAnchor, constant: DesignSystem.Spacing.l),
            stackView.trailingAnchor.constraint(equalTo: formCardView.trailingAnchor, constant: -DesignSystem.Spacing.l),
            stackView.bottomAnchor.constraint(equalTo: formCardView.bottomAnchor, constant: -DesignSystem.Spacing.xxl),

            loadingView.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: centerYAnchor),
            loadingView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: DesignSystem.Spacing.xxl),
            loadingView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -DesignSystem.Spacing.xxl)
        ])
    }

    func setupActions() {
        emailTextField.addTarget(self, action: #selector(emailChanged), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(passwordChanged), for: .editingChanged)
        primaryButton.addTarget(self, action: #selector(primaryTapped), for: .touchUpInside)
        switchModeButton.addTarget(self, action: #selector(switchModeTapped), for: .touchUpInside)
    }

    func renderMode(_ mode: AuthMode) {
        switch mode {
        case .login:
            headerLabel.text = "Вход"
            primaryButton.setTitle("Войти", for: .normal)
            switchModeButton.setTitle("Нет аккаунта? Зарегистрироваться", for: .normal)

        case .register:
            headerLabel.text = "Регистрация"
            primaryButton.setTitle("Зарегистрироваться", for: .normal)
            switchModeButton.setTitle("Уже есть аккаунт? Войти", for: .normal)
        }
    }

    func renderFields(email: String, password: String) {
        if emailTextField.text != email {
            emailTextField.text = email
        }

        if passwordTextField.text != password {
            passwordTextField.text = password
        }
    }

    func renderScreen(_ screen: LoadableState<AuthContent>) {
        switch screen {
        case .initial:
            loadingView.stopAnimating()
            loadingView.isHidden = true
            messageView.isHidden = true
            emailTextField.setError(nil)
            passwordTextField.setError(nil)

        case .loading:
            loadingView.isHidden = false
            loadingView.startAnimating()
            messageView.isHidden = true
            emailTextField.setError(nil)
            passwordTextField.setError(nil)

        case .content:
            loadingView.stopAnimating()
            loadingView.isHidden = true
            messageView.isHidden = true
            emailTextField.setError(nil)
            passwordTextField.setError(nil)

        case .empty(let message):
            loadingView.stopAnimating()
            loadingView.isHidden = true
            showMessage(title: "Пока ничего нет", message: message)
            emailTextField.setError(nil)
            passwordTextField.setError(nil)

        case .error(let message):
            loadingView.stopAnimating()
            loadingView.isHidden = true
            showMessage(title: "Ошибка", message: message)
            emailTextField.setError(nil)
            passwordTextField.setError(nil)
        }
    }

    func renderActions(_ state: AuthViewState) {
        let isLoading: Bool

        switch state.screen {
        case .loading:
            isLoading = true
        default:
            isLoading = false
        }

        primaryButton.isEnabled = state.isPrimaryButtonEnabled && !isLoading
        switchModeButton.isEnabled = !isLoading
    }

    func showMessage(title: String, message: String) {
        messageView.configure(title: title, message: message, actionTitle: nil)
        messageView.isHidden = false
    }

    @objc func emailChanged() {
        onEmailChanged?(emailTextField.text ?? "")
    }

    @objc func passwordChanged() {
        onPasswordChanged?(passwordTextField.text ?? "")
    }

    @objc func primaryTapped() {
        onPrimaryTap?()
    }

    @objc func switchModeTapped() {
        onSwitchModeTap?()
    }
}
