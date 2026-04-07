import UIKit

enum FeaturesAssembly {
    static func make() -> UIViewController {
        let viewController = FeaturesViewController()
        let router = FeaturesRouterImpl()
        let authService = AuthServiceImpl()
        let featuresService = FeaturesServiceImpl()

        let viewModel = FeaturesViewModelImpl(
            router: router,
            authService: authService,
            featuresService: featuresService
        )

        viewController.viewModel = viewModel
        router.viewController = viewController

        return viewController
    }
}
