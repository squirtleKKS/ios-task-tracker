import UIKit

enum ProfileAssembly {
    static func make() -> UIViewController {
        let configuration = BackendDrivenScreenConfiguration(
            endpoint: URL(string: "https://alfa-itmo.ru/server/v1/storage/profile_screen")!
        )

        let loader = LocalScreenProvider()

        let actionHandler = ProfileBDUIActionHandler()
        let mapper = BDUIViewMapper(actionHandler: actionHandler)

        let viewModel = BackendDrivenScreenViewModel(
            configuration: configuration,
            loader: loader,
            mapper: mapper
        )

        let viewController = BackendDrivenScreenViewController(
            viewModel: viewModel
        )

        actionHandler.onBack = { [weak viewController] in
            viewController?.navigationController?.popViewController(animated: true)
        }

        return viewController
    }
}
