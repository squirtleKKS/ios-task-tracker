import Foundation

struct BDUIAction: Decodable, Equatable {
    let type: BDUIActionType
    let payload: [String: String]?
}

enum BDUIActionType: String, Decodable, Equatable {
    case print
    case route
}
