import Foundation

protocol FeaturesViewModel: AnyObject {
    func onAppear()
    func didSelectFeature(id: FeatureID)
    func didTapLogout()
}
