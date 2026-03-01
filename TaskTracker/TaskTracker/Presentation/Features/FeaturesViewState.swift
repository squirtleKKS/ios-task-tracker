import Foundation

struct FeaturesViewState: Equatable {
    var screen: LoadableState<[FeatureItemVM]>
}

struct FeatureItemVM: Equatable {
    let id: FeatureID
    let title: String
    let subtitle: String?
    let isEnabled: Bool
    let kind: AppFeatureKind
}
