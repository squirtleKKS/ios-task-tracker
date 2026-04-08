import UIKit

enum DesignSystem {

    enum Colors {
        static let background = UIColor(named: "DSBackground") ?? UIColor.systemBackground
        static let surface = UIColor(named: "DSSurface") ?? UIColor.secondarySystemBackground
        static let surfaceSecondary = UIColor(named: "DSSurfaceSecondary") ?? UIColor.systemGroupedBackground

        static let primary = UIColor(named: "DSPrimary") ?? .systemPink
        static let primaryPressed = UIColor(named: "DSPrimaryPressed") ?? UIColor.systemPink.withAlphaComponent(0.85)
        static let primaryDisabled = UIColor(named: "DSPrimaryDisabled") ?? UIColor.systemPink.withAlphaComponent(0.4)

        static let textPrimary = UIColor(named: "DSTextPrimary") ?? UIColor.label
        static let textSecondary = UIColor(named: "DSTextSecondary") ?? UIColor.secondaryLabel
        static let textOnPrimary = UIColor.white

        static let border = UIColor(named: "DSBorder") ?? UIColor.systemGray5
        static let separator = UIColor(named: "DSSeparator") ?? UIColor.systemGray6

        static let error = UIColor(named: "DSError") ?? UIColor.systemRed
        static let success = UIColor(named: "DSSuccess") ?? UIColor.systemGreen

        static let shadow = UIColor.black.withAlphaComponent(0.06)
    }

    enum Spacing {
        static let xs: CGFloat = 4
        static let s: CGFloat = 8
        static let m: CGFloat = 12
        static let l: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
    }

    enum CornerRadius {
        static let s: CGFloat = 10
        static let m: CGFloat = 16
        static let l: CGFloat = 22
        static let pill: CGFloat = 26
    }

    enum Typography {
        static func largeTitle() -> UIFont {
            .systemFont(ofSize: 34, weight: .bold)
        }

        static func title() -> UIFont {
            .systemFont(ofSize: 28, weight: .bold)
        }

        static func heading() -> UIFont {
            .systemFont(ofSize: 18, weight: .semibold)
        }

        static func body() -> UIFont {
            .systemFont(ofSize: 16, weight: .regular)
        }

        static func bodyMedium() -> UIFont {
            .systemFont(ofSize: 16, weight: .medium)
        }

        static func caption() -> UIFont {
            .systemFont(ofSize: 13, weight: .regular)
        }

        static func captionMedium() -> UIFont {
            .systemFont(ofSize: 13, weight: .medium)
        }

        static func button() -> UIFont {
            .systemFont(ofSize: 18, weight: .semibold)
        }
    }

    enum Sizes {
        static let buttonHeight: CGFloat = 56
        static let textFieldHeight: CGFloat = 56
        static let iconSmall: CGFloat = 16
        static let iconMedium: CGFloat = 24
    }
}

enum TextStyle {
    case largeTitle
    case title
    case heading
    case body
    case bodySecondary
    case caption
    case captionSecondary
    case error
    case button

    var font: UIFont {
        switch self {
        case .largeTitle:
            return DesignSystem.Typography.largeTitle()
        case .title:
            return DesignSystem.Typography.title()
        case .heading:
            return DesignSystem.Typography.heading()
        case .body:
            return DesignSystem.Typography.body()
        case .bodySecondary:
            return DesignSystem.Typography.body()
        case .caption:
            return DesignSystem.Typography.caption()
        case .captionSecondary:
            return DesignSystem.Typography.caption()
        case .error:
            return DesignSystem.Typography.captionMedium()
        case .button:
            return DesignSystem.Typography.button()
        }
    }

    var color: UIColor {
        switch self {
        case .largeTitle, .title, .heading, .body, .button:
            return DesignSystem.Colors.textPrimary
        case .bodySecondary, .captionSecondary:
            return DesignSystem.Colors.textSecondary
        case .caption:
            return DesignSystem.Colors.textPrimary
        case .error:
            return DesignSystem.Colors.error
        }
    }
}

extension UILabel {
    func apply(_ style: TextStyle) {
        font = style.font
        textColor = style.color
    }
}

extension UIView {
    func applyCardStyle() {
        backgroundColor = DesignSystem.Colors.surface
        layer.cornerRadius = DesignSystem.CornerRadius.l
        layer.borderWidth = 1
        layer.borderColor = DesignSystem.Colors.border.cgColor
        layer.shadowColor = DesignSystem.Colors.shadow.cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: 4)
    }
}
