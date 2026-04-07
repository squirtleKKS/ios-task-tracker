import Foundation

@MainActor
protocol FeaturesViewModel: AnyObject {
    var state: FeaturesViewState { get }
    var onStateChange: ((FeaturesViewState) -> Void)? { get set }

    func onAppear()
    func didSelectFeature(id: FeatureID)
    func didTapLogout()
}
