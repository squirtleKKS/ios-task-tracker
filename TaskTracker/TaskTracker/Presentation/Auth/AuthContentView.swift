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
    private let emailTextField = DSTextField()
    private let passwordTextField = DSTextField()
    private let primaryButton = DSButton()
    private let switchModeButton = DSButton()
    private let loadingView = DSLoadingView()
    private let messageView = DSMessageView()

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
        headerLabel.text = state.mode == .login ? "Вход" : "Регистрация"
        emailTextField.configure(makeEmailConfiguration(email: state.email))
        passwordTextField.configure(makePasswordConfiguration(password: state.password))
        primaryButton.configure(makePrimaryButtonConfiguration(state: state))
        switchModeButton.configure(makeSwitchModeButtonConfiguration(state: state))
        loadingView.configure(makeLoadingConfiguration(screen: state.screen))
        messageView.configure(makeMessageConfiguration(screen: state.screen))
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

    func makeEmailConfiguration(email: String) -> DSTextFieldConfiguration {
        DSTextFieldConfiguration(
            title: "Email",
            placeholder: "Введите email",
            text: email,
            errorMessage: nil,
            isSecureEntry: false,
            keyboardType: .emailAddress,
            returnKeyType: .next,
            autocapitalizationType: .none,
            autocorrectionType: .no,
            accessibilityIdentifier: "auth.email",
            isHidden: false
        )
    }

    func makePasswordConfiguration(password: String) -> DSTextFieldConfiguration {
        DSTextFieldConfiguration(
            title: "Пароль",
            placeholder: "Введите пароль",
            text: password,
            errorMessage: nil,
            isSecureEntry: true,
            keyboardType: .default,
            returnKeyType: .done,
            autocapitalizationType: .none,
            autocorrectionType: .no,
            accessibilityIdentifier: "auth.password",
            isHidden: false
        )
    }

    func makePrimaryButtonConfiguration(state: AuthViewState) -> DSButtonConfiguration {
        let isLoading: Bool

        switch state.screen {
        case .loading:
            isLoading = true
        default:
            isLoading = false
        }

        return DSButtonConfiguration(
            title: state.mode == .login ? "Войти" : "Зарегистрироваться",
            style: .primary,
            isEnabled: state.isPrimaryButtonEnabled && !isLoading,
            isHidden: false,
            accessibilityIdentifier: "auth.primary"
        )
    }

    func makeSwitchModeButtonConfiguration(state: AuthViewState) -> DSButtonConfiguration {
        let isLoading: Bool

        switch state.screen {
        case .loading:
            isLoading = true
        default:
            isLoading = false
        }

        return DSButtonConfiguration(
            title: state.mode == .login
                ? "Нет аккаунта? Зарегистрироваться"
                : "Уже есть аккаунт? Войти",
            style: .secondary,
            isEnabled: !isLoading,
            isHidden: false,
            accessibilityIdentifier: "auth.switchMode"
        )
    }

    func makeLoadingConfiguration(screen: LoadableState<AuthContent>) -> DSLoadingViewConfiguration {
        switch screen {
        case .loading:
            return DSLoadingViewConfiguration(
                text: "Проверяем данные...",
                isHidden: false,
                isAnimating: true
            )
        default:
            return DSLoadingViewConfiguration(
                text: "Проверяем данные...",
                isHidden: true,
                isAnimating: false
            )
        }
    }

    func makeMessageConfiguration(screen: LoadableState<AuthContent>) -> DSMessageViewConfiguration {
        switch screen {
        case .empty(let message):
            return DSMessageViewConfiguration(
                style: .empty,
                title: "Пока ничего нет",
                message: message,
                actionTitle: nil,
                isHidden: false
            )

        case .error(let message):
            return DSMessageViewConfiguration(
                style: .error,
                title: "Ошибка",
                message: message,
                actionTitle: nil,
                isHidden: false
            )

        default:
            return DSMessageViewConfiguration(isHidden: true)
        }
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
