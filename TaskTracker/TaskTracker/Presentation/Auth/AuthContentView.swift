import UIKit

final class AuthContentView: UIView {

    let scrollView = UIScrollView()
    let containerView = UIView()
    let headerLabel = UILabel()
    let emailTextField = DSTextField(title: "Email", placeholder: "Введите email")
    let passwordTextField = DSTextField(title: "Пароль", placeholder: "Введите пароль")
    let errorLabel = UILabel()
    let primaryButton = DSButton(style: .primary)
    let switchModeButton = DSButton(style: .secondary)
    let loadingView = DSLoadingView(text: "Проверяем данные...")

    private let formCardView = UIView()
    private let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
}

private extension AuthContentView {
    func setupUI() {
        backgroundColor = DesignSystem.Colors.background

        [scrollView, containerView, headerLabel, formCardView, stackView, loadingView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        stackView.axis = .vertical
        stackView.spacing = DesignSystem.Spacing.l

        headerLabel.apply(.title)
        headerLabel.text = "Вход"
        headerLabel.textAlignment = .center

        formCardView.applyCardStyle()

        emailTextField.textField.keyboardType = .emailAddress
        emailTextField.textField.autocapitalizationType = .none
        emailTextField.textField.autocorrectionType = .no
        emailTextField.textField.returnKeyType = .next
        emailTextField.textField.accessibilityIdentifier = "auth.email"

        passwordTextField.setSecureEntry(true)
        passwordTextField.textField.autocapitalizationType = .none
        passwordTextField.textField.autocorrectionType = .no
        passwordTextField.textField.returnKeyType = .done
        passwordTextField.textField.accessibilityIdentifier = "auth.password"

        errorLabel.apply(.error)
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true

        loadingView.isHidden = true

        addSubview(scrollView)
        addSubview(loadingView)
        scrollView.addSubview(containerView)
        containerView.addSubview(formCardView)
        formCardView.addSubview(stackView)

        [
            headerLabel,
            emailTextField,
            passwordTextField,
            errorLabel,
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
}
