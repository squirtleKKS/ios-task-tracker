import UIKit

final class DSTextField: UIView {

    private let titleLabel = UILabel()
    private let containerView = UIView()
    let textField = UITextField()
    private let errorLabel = UILabel()

    init(title: String? = nil, placeholder: String? = nil) {
        super.init(frame: .zero)
        setup()
        configure(title: title, placeholder: placeholder)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    var text: String? {
        get { textField.text }
        set { textField.text = newValue }
    }

    func configure(title: String?, placeholder: String?) {
        titleLabel.text = title
        textField.placeholder = placeholder
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder ?? "",
            attributes: [.foregroundColor: DesignSystem.Colors.textSecondary.withAlphaComponent(0.45)]
        )
    }

    func setError(_ message: String?) {
        let hasError = !(message?.isEmpty ?? true)
        errorLabel.text = message
        errorLabel.isHidden = !hasError
        containerView.layer.borderColor = hasError
            ? DesignSystem.Colors.error.cgColor
            : DesignSystem.Colors.border.cgColor
    }

    func setSecureEntry(_ isSecure: Bool) {
        textField.isSecureTextEntry = isSecure
    }

    func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
        textField.addTarget(target, action: action, for: controlEvents)
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
}
