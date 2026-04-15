import Foundation

struct BDUINode: Decodable, Equatable {
    let type: BDUINodeType
    let props: BDUIProps
    let layout: BDUILayout?
    let subviews: [BDUINode]

    private enum CodingKeys: String, CodingKey {
        case type
        case props
        case layout
        case subviews
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(BDUINodeType.self, forKey: .type)

        self.type = type
        self.layout = try container.decodeIfPresent(BDUILayout.self, forKey: .layout)
        self.subviews = try container.decodeIfPresent([BDUINode].self, forKey: .subviews) ?? []
        self.props = try BDUIProps(from: decoder, type: type)
    }
}

enum BDUINodeType: String, Decodable, Equatable {
    case container
    case stack
    case label
    case button
    case textField
    case message
    case loading
}

struct BDUILayout: Decodable, Equatable {
    let padding: BDUIEdgeInsets?
    let width: CGFloat?
    let height: CGFloat?
    let backgroundColor: BDUIColorToken?
}

struct BDUIEdgeInsets: Decodable, Equatable {
    let top: BDUISpacingToken?
    let left: BDUISpacingToken?
    let bottom: BDUISpacingToken?
    let right: BDUISpacingToken?
}
