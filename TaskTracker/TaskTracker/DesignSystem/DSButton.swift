import UIKit

final class DSButton: UIButton {

    enum Style {
        case primary
        case secondary
    }

    private let styleType: Style

    init(style: Style) {
        self.styleType = style
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override var isEnabled: Bool {
        didSet {
            applyStyle()
        }
    }

    override var isHighlighted: Bool {
        didSet {
            applyStyle()
        }
    }

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        titleLabel?.font = DesignSystem.Typography.button()
        layer.cornerRadius = DesignSystem.CornerRadius.m
        clipsToBounds = true
        heightAnchor.constraint(equalToConstant: DesignSystem.Sizes.buttonHeight).isActive = true
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
}
