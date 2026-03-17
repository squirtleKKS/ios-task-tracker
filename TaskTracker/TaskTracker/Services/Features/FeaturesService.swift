import Foundation

protocol FeaturesService {
    func getFeatures() async throws -> [AppFeature]
}
