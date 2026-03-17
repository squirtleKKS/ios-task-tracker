import Foundation

struct AppFeature: Equatable, Codable {
    let id: FeatureID
    let kind: AppFeatureKind
    let title: String
    let subtitle: String?
    let isEnabled: Bool
}
