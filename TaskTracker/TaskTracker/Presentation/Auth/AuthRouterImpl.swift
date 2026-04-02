import UIKit

final class AuthRouterImpl: AuthRouter {
    weak var viewController: UIViewController?

    func openFeatures() {
        let featuresViewController = FeaturesAssembly.make()
        viewController?.navigationController?.setViewControllers([featuresViewController], animated: true)
    }
}
