import UIKit

final class DSMessageView: UIView {

    enum Style {
        case empty
        case error
    }

    let actionButton = DSButton(style: .secondary)

    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let stackView = UIStackView()

    init(style: Style, title: String, message: String, actionTitle: String? = nil) {
        super.init(frame: .zero)
        setup(style: style, title: title, message: message, actionTitle: actionTitle)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func configure(title: String, message: String, actionTitle: String?) {
        titleLabel.text = title
        messageLabel.text = message

        if let actionTitle, !actionTitle.isEmpty {
            actionButton.isHidden = false
            actionButton.setTitle(actionTitle, for: .normal)
        } else {
            actionButton.isHidden = true
        }
    }

    private func setup(style: Style, title: String, message: String, actionTitle: String?) {
        translatesAutoresizingMaskIntoConstraints = false

        backgroundColor = DesignSystem.Colors.surface
        layer.cornerRadius = DesignSystem.CornerRadius.l
        layer.borderWidth = 1
        layer.borderColor = DesignSystem.Colors.border.cgColor
        layer.shadowColor = DesignSystem.Colors.shadow.cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: 4)

        [titleLabel, messageLabel, stackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        titleLabel.apply(.heading)
        titleLabel.textAlignment = .center

        messageLabel.apply(style == .error ? .error : .bodySecondary)
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center

        stackView.axis = .vertical
        stackView.spacing = DesignSystem.Spacing.m
        stackView.alignment = .fill

        addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(messageLabel)
        stackView.addArrangedSubview(actionButton)

        configure(title: title, message: message, actionTitle: actionTitle)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: DesignSystem.Spacing.xl),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: DesignSystem.Spacing.l),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -DesignSystem.Spacing.l),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -DesignSystem.Spacing.xl)
        ])
    }
}
