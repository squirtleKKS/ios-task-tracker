import UIKit

struct DSMessageViewConfiguration {
    let style: DSMessageView.Style
    let title: String?
    let message: String?
    let actionTitle: String?
    let isHidden: Bool

    init(
        style: DSMessageView.Style = .empty,
        title: String? = nil,
        message: String? = nil,
        actionTitle: String? = nil,
        isHidden: Bool = true
    ) {
        self.style = style
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.isHidden = isHidden
    }
}

final class DSMessageView: UIView {

    enum Style {
        case empty
        case error
    }

    let actionButton = DSButton()

    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let stackView = UIStackView()

    init(configuration: DSMessageViewConfiguration = .init()) {
        super.init(frame: .zero)
        setup()
        configure(configuration)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func configure(_ configuration: DSMessageViewConfiguration) {
        isHidden = configuration.isHidden
        titleLabel.text = configuration.title
        messageLabel.text = configuration.message
        messageLabel.apply(configuration.style == .error ? .error : .bodySecondary)

        let hasAction = !(configuration.actionTitle?.isEmpty ?? true)

        actionButton.configure(
            DSButtonConfiguration(
                title: configuration.actionTitle,
                style: .secondary,
                isEnabled: true,
                isHidden: !hasAction
            )
        )
    }

    private func setup() {
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

        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center

        stackView.axis = .vertical
        stackView.spacing = DesignSystem.Spacing.m
        stackView.alignment = .fill

        addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(messageLabel)
        stackView.addArrangedSubview(actionButton)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: DesignSystem.Spacing.xl),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: DesignSystem.Spacing.l),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -DesignSystem.Spacing.l),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -DesignSystem.Spacing.xl)
        ])
    }
}
