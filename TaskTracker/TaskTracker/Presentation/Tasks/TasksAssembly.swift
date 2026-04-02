import UIKit

enum TasksAssembly {
    static func make() -> UIViewController {
        let client = URLSessionNetworkClient()
        let repository = TasksRepositoryImpl(client: client)
        let service = TasksServiceImpl(repository: repository)
        let router = TasksRouterImpl()
        let viewController = TasksViewController()
        let viewModel = TasksViewModelImpl(
            service: service,
            router: router
        )

        viewController.viewModel = viewModel
        router.viewController = viewController

        return viewController
    }
}
