import UIKit

enum AuthAssembly {
    static func make() -> UIViewController {
        let viewController = AuthViewController()
        let router = AuthRouterImpl()
        let authService = AuthServiceImpl()

        let viewModel = AuthViewModelImpl(
            view: viewController,
            router: router,
            authService: authService
        )

        viewController.viewModel = viewModel
        router.viewController = viewController

        return viewController
    }
}
