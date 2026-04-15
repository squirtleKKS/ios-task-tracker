import UIKit

enum BDUISpacingToken: String, Decodable, Equatable {
    case xs
    case s
    case m
    case l
    case xl
    case xxl

    var value: CGFloat {
        switch self {
        case .xs: return DesignSystem.Spacing.xs
        case .s: return DesignSystem.Spacing.s
        case .m: return DesignSystem.Spacing.m
        case .l: return DesignSystem.Spacing.l
        case .xl: return DesignSystem.Spacing.xl
        case .xxl: return DesignSystem.Spacing.xxl
        }
    }
}

enum BDUIColorToken: String, Decodable, Equatable {
    case background
    case surface
    case surfaceSecondary
    case primary
    case textPrimary
    case textSecondary
    case error

    var value: UIColor {
        switch self {
        case .background: return DesignSystem.Colors.background
        case .surface: return DesignSystem.Colors.surface
        case .surfaceSecondary: return DesignSystem.Colors.surfaceSecondary
        case .primary: return DesignSystem.Colors.primary
        case .textPrimary: return DesignSystem.Colors.textPrimary
        case .textSecondary: return DesignSystem.Colors.textSecondary
        case .error: return DesignSystem.Colors.error
        }
    }
}

enum BDUITextStyleToken: String, Decodable, Equatable {
    case largeTitle
    case title
    case heading
    case body
    case bodySecondary
    case caption
    case captionSecondary
    case error
    case button

    var value: TextStyle {
        switch self {
        case .largeTitle: return .largeTitle
        case .title: return .title
        case .heading: return .heading
        case .body: return .body
        case .bodySecondary: return .bodySecondary
        case .caption: return .caption
        case .captionSecondary: return .captionSecondary
        case .error: return .error
        case .button: return .button
        }
    }
}

enum BDUIButtonStyleToken: String, Decodable, Equatable {
    case primary
    case secondary

    var value: DSButton.Style {
        switch self {
        case .primary: return .primary
        case .secondary: return .secondary
        }
    }
}

enum BDUIMessageStyleToken: String, Decodable, Equatable {
    case empty
    case error

    var value: DSMessageView.Style {
        switch self {
        case .empty: return .empty
        case .error: return .error
        }
    }
}

enum BDUIAxisToken: String, Decodable, Equatable {
    case vertical
    case horizontal

    var value: NSLayoutConstraint.Axis {
        switch self {
        case .vertical: return .vertical
        case .horizontal: return .horizontal
        }
    }
}

enum BDUIStackAlignmentToken: String, Decodable, Equatable {
    case fill
    case leading
    case center
    case trailing

    var value: UIStackView.Alignment {
        switch self {
        case .fill: return .fill
        case .leading: return .leading
        case .center: return .center
        case .trailing: return .trailing
        }
    }
}

enum BDUIStackDistributionToken: String, Decodable, Equatable {
    case fill
    case fillEqually
    case equalSpacing

    var value: UIStackView.Distribution {
        switch self {
        case .fill: return .fill
        case .fillEqually: return .fillEqually
        case .equalSpacing: return .equalSpacing
        }
    }
}

enum BDUITextAlignmentToken: String, Decodable, Equatable {
    case left
    case center
    case right
    case natural

    var value: NSTextAlignment {
        switch self {
        case .left: return .left
        case .center: return .center
        case .right: return .right
        case .natural: return .natural
        }
    }
}
