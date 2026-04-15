import Foundation

enum BDUIProps: Equatable {
    case container(BDUIContainerProps)
    case stack(BDUIStackProps)
    case label(BDUILabelProps)
    case button(BDUIButtonProps)
    case textField(BDUITextFieldProps)
    case message(BDUIMessageProps)
    case loading(BDUILoadingProps)

    init(from decoder: Decoder, type: BDUINodeType) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        switch type {
        case .container:
            let props = try container.decode(BDUIContainerProps.self, forKey: .props)
            self = .container(props)

        case .stack:
            let props = try container.decode(BDUIStackProps.self, forKey: .props)
            self = .stack(props)

        case .label:
            let props = try container.decode(BDUILabelProps.self, forKey: .props)
            self = .label(props)

        case .button:
            let props = try container.decode(BDUIButtonProps.self, forKey: .props)
            self = .button(props)

        case .textField:
            let props = try container.decode(BDUITextFieldProps.self, forKey: .props)
            self = .textField(props)

        case .message:
            let props = try container.decode(BDUIMessageProps.self, forKey: .props)
            self = .message(props)

        case .loading:
            let props = try container.decode(BDUILoadingProps.self, forKey: .props)
            self = .loading(props)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case props
    }
}

struct BDUIContainerProps: Decodable, Equatable {
    let cardStyle: Bool?
}

struct BDUIStackProps: Decodable, Equatable {
    let axis: BDUIAxisToken
    let spacing: BDUISpacingToken
    let alignment: BDUIStackAlignmentToken?
    let distribution: BDUIStackDistributionToken?
}

struct BDUILabelProps: Decodable, Equatable {
    let text: String
    let style: BDUITextStyleToken
    let textAlignment: BDUITextAlignmentToken?
    let numberOfLines: Int?
}

struct BDUIButtonProps: Decodable, Equatable {
    let title: String
    let style: BDUIButtonStyleToken
    let action: BDUIAction?
}

struct BDUITextFieldProps: Decodable, Equatable {
    let title: String?
    let placeholder: String?
    let text: String?
    let isSecure: Bool?
}

struct BDUIMessageProps: Decodable, Equatable {
    let style: BDUIMessageStyleToken
    let title: String
    let message: String
    let actionTitle: String?
    let action: BDUIAction?
}

struct BDUILoadingProps: Decodable, Equatable {
    let text: String
    let isAnimating: Bool?
}
