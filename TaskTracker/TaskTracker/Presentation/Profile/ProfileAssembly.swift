import UIKit

enum ProfileAssembly {
    static func make() -> UIViewController {
        let actionHandler = ProfileBDUIActionHandler()
        let mapper = BDUIViewMapper(actionHandler: actionHandler)
        let loader = LocalScreenProvider()

        let loadingView = DSLoadingView(
            configuration: DSLoadingViewConfiguration(
                text: "Загружаем профиль...",
                isHidden: false,
                isAnimating: true
            )
        )

        let configuration = BackendDrivenScreenConfiguration(
            endpoint: URL(string: "https://alfa-itmo.ru/server/v1/storage/profile_screen")!
        )

        let viewController = BackendDrivenScreenViewController(
            configuration: configuration,
            loader: loader,
            mapper: mapper,
            loadingView: loadingView,
            actionHandler: actionHandler
        )

        actionHandler.onBack = { [weak viewController] in
            viewController?.navigationController?.popViewController(animated: true)
        }

        viewController.onError = { error in
            print(error)
        }

        return viewController
    }
}
