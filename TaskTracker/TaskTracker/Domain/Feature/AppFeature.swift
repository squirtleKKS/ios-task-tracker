import Foundation

struct AppFeature: Equatable {
    let id: FeatureID
    let kind: AppFeatureKind
    let title: String
    let subtitle: String?
    let isEnabled: Bool
}
