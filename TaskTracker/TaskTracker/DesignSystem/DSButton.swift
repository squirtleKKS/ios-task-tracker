import UIKit

struct DSButtonConfiguration {
    let title: String?
    let style: DSButton.Style
    let isEnabled: Bool
    let isHidden: Bool
    let accessibilityIdentifier: String?
    let onTap: (() -> Void)?

    init(
        title: String? = nil,
        style: DSButton.Style = .primary,
        isEnabled: Bool = true,
        isHidden: Bool = false,
        accessibilityIdentifier: String? = nil,
        onTap: (() -> Void)? = nil
    ) {
        self.title = title
        self.style = style
        self.isEnabled = isEnabled
        self.isHidden = isHidden
        self.accessibilityIdentifier = accessibilityIdentifier
        self.onTap = onTap
    }
}

final class DSButton: UIButton {

    enum Style {
        case primary
        case secondary
    }

    private var styleType: Style = .primary
    private var onTap: (() -> Void)?

    init(configuration: DSButtonConfiguration = .init()) {
        super.init(frame: .zero)
        setup()
        configure(configuration)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override var isHighlighted: Bool {
        didSet {
            applyStyle()
        }
    }

    func configure(_ configuration: DSButtonConfiguration) {
        styleType = configuration.style
        setTitle(configuration.title, for: .normal)
        super.isEnabled = configuration.isEnabled
        super.isHidden = configuration.isHidden
        accessibilityIdentifier = configuration.accessibilityIdentifier
        onTap = configuration.onTap
        applyStyle()
    }

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        titleLabel?.font = DesignSystem.Typography.button()
        layer.cornerRadius = DesignSystem.CornerRadius.m
        clipsToBounds = true
        heightAnchor.constraint(equalToConstant: DesignSystem.Sizes.buttonHeight).isActive = true
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        applyStyle()
    }

    private func applyStyle() {
        switch styleType {
        case .primary:
            backgroundColor = primaryBackgroundColor()
            setTitleColor(DesignSystem.Colors.textOnPrimary, for: .normal)
            layer.borderWidth = 0
            alpha = isEnabled ? 1 : 0.9
            transform = isHighlighted ? CGAffineTransform(scaleX: 0.985, y: 0.985) : .identity

        case .secondary:
            backgroundColor = isHighlighted
                ? DesignSystem.Colors.surfaceSecondary
                : DesignSystem.Colors.surface
            setTitleColor(DesignSystem.Colors.primary, for: .normal)
            layer.borderWidth = 1
            layer.borderColor = DesignSystem.Colors.border.cgColor
            alpha = isEnabled ? 1 : 0.9
            transform = isHighlighted ? CGAffineTransform(scaleX: 0.985, y: 0.985) : .identity
        }
    }

    private func primaryBackgroundColor() -> UIColor {
        if !isEnabled {
            return DesignSystem.Colors.primaryDisabled
        }

        if isHighlighted {
            return DesignSystem.Colors.primaryPressed
        }

        return DesignSystem.Colors.primary
    }

    @objc private func handleTap() {
        onTap?()
    }
}
