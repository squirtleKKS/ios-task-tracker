import UIKit

struct DSTextFieldConfiguration {
    let title: String?
    let placeholder: String?
    let text: String?
    let errorMessage: String?
    let isSecureEntry: Bool
    let keyboardType: UIKeyboardType
    let returnKeyType: UIReturnKeyType
    let autocapitalizationType: UITextAutocapitalizationType
    let autocorrectionType: UITextAutocorrectionType
    let accessibilityIdentifier: String?
    let isHidden: Bool
    let onTextChanged: ((String) -> Void)?

    init(
        title: String? = nil,
        placeholder: String? = nil,
        text: String? = nil,
        errorMessage: String? = nil,
        isSecureEntry: Bool = false,
        keyboardType: UIKeyboardType = .default,
        returnKeyType: UIReturnKeyType = .default,
        autocapitalizationType: UITextAutocapitalizationType = .sentences,
        autocorrectionType: UITextAutocorrectionType = .default,
        accessibilityIdentifier: String? = nil,
        isHidden: Bool = false,
        onTextChanged: ((String) -> Void)? = nil
    ) {
        self.title = title
        self.placeholder = placeholder
        self.text = text
        self.errorMessage = errorMessage
        self.isSecureEntry = isSecureEntry
        self.keyboardType = keyboardType
        self.returnKeyType = returnKeyType
        self.autocapitalizationType = autocapitalizationType
        self.autocorrectionType = autocorrectionType
        self.accessibilityIdentifier = accessibilityIdentifier
        self.isHidden = isHidden
        self.onTextChanged = onTextChanged
    }
}

final class DSTextField: UIView {

    private let titleLabel = UILabel()
    private let containerView = UIView()
    private let textField = UITextField()
    private let errorLabel = UILabel()

    private var onTextChanged: ((String) -> Void)?

    init(configuration: DSTextFieldConfiguration = .init()) {
        super.init(frame: .zero)
        setup()
        configure(configuration)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    var text: String? {
        textField.text
    }

    func configure(_ configuration: DSTextFieldConfiguration) {
        isHidden = configuration.isHidden
        titleLabel.text = configuration.title
        textField.placeholder = configuration.placeholder
        textField.attributedPlaceholder = NSAttributedString(
            string: configuration.placeholder ?? "",
            attributes: [
                .foregroundColor: DesignSystem.Colors.textSecondary.withAlphaComponent(0.45)
            ]
        )

        if textField.text != configuration.text {
            textField.text = configuration.text
        }

        if textField.isSecureTextEntry != configuration.isSecureEntry {
            textField.isSecureTextEntry = configuration.isSecureEntry
        }

        textField.keyboardType = configuration.keyboardType
        textField.returnKeyType = configuration.returnKeyType
        textField.autocapitalizationType = configuration.autocapitalizationType
        textField.autocorrectionType = configuration.autocorrectionType
        textField.accessibilityIdentifier = configuration.accessibilityIdentifier
        onTextChanged = configuration.onTextChanged

        let hasError = !(configuration.errorMessage?.isEmpty ?? true)
        errorLabel.text = configuration.errorMessage
        errorLabel.isHidden = !hasError
        containerView.layer.borderColor = hasError
            ? DesignSystem.Colors.error.cgColor
            : DesignSystem.Colors.border.cgColor
    }

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false

        [titleLabel, containerView, textField, errorLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        titleLabel.apply(.captionSecondary)

        containerView.backgroundColor = DesignSystem.Colors.surface
        containerView.layer.cornerRadius = DesignSystem.CornerRadius.m
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = DesignSystem.Colors.border.cgColor

        textField.font = DesignSystem.Typography.body()
        textField.textColor = DesignSystem.Colors.textPrimary
        textField.tintColor = DesignSystem.Colors.primary
        textField.borderStyle = .none
        textField.clearButtonMode = .whileEditing
        textField.addTarget(self, action: #selector(handleEditingChanged), for: .editingChanged)

        errorLabel.apply(.error)
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true

        addSubview(titleLabel)
        addSubview(containerView)
        addSubview(errorLabel)
        containerView.addSubview(textField)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

            containerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: DesignSystem.Spacing.xs),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.heightAnchor.constraint(equalToConstant: DesignSystem.Sizes.textFieldHeight),

            textField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: DesignSystem.Spacing.l),
            textField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -DesignSystem.Spacing.l),
            textField.topAnchor.constraint(equalTo: containerView.topAnchor),
            textField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

            errorLabel.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: DesignSystem.Spacing.xs),
            errorLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            errorLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    @objc private func handleEditingChanged() {
        onTextChanged?(textField.text ?? "")
    }
}
