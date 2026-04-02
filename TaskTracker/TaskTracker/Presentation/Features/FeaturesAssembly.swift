import UIKit

enum FeaturesAssembly {
    static func make() -> UIViewController {
        let viewController = FeaturesViewController()
        let router = FeaturesRouterImpl()
        let authService = AuthServiceImpl()

        let viewModel = FeaturesViewModelImpl(
            view: viewController,
            router: router,
            authService: authService
        )

        viewController.viewModel = viewModel
        router.viewController = viewController

        return viewController
    }
}
