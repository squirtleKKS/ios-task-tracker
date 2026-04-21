import UIKit

final class FeaturesRouterImpl: FeaturesRouter {
    weak var viewController: UIViewController?

    func openTasks() {
        let controller = TasksAssembly.make()

        if let navigationController = viewController?.navigationController {
            navigationController.pushViewController(controller, animated: true)
        } else {
            viewController?.present(controller, animated: true)
        }
    }
    
    func openBDUI() {
        let controller = ProfileAssembly.make()
        if let navigationController = viewController?.navigationController {
            navigationController.pushViewController(controller, animated: true)
        } else {
            viewController?.present(controller, animated: true)
        }
    }

    func openStatistics() {
        pushStub(title: "Статистика")
    }

    func openReminders() {
        pushStub(title: "Напоминания")
    }

    func openAuth() {
        let authController = AuthAssembly.make()

        if let navigationController = viewController?.navigationController {
            navigationController.setViewControllers([authController], animated: true)
        } else {
            viewController?.present(authController, animated: true)
        }
    }

    private func pushStub(title: String) {
        let controller = StubViewController(screenTitle: title)

        if let navigationController = viewController?.navigationController {
            navigationController.pushViewController(controller, animated: true)
        } else {
            viewController?.present(controller, animated: true)
        }
    }
}
