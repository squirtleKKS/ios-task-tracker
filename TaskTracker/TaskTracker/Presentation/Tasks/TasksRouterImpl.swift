import UIKit

final class TasksRouterImpl: TasksRouter {
    weak var viewController: UIViewController?

    func openTaskDetails(taskId: TaskID) {
        let controller = UIViewController()
        controller.view.backgroundColor = .systemBackground
        controller.title = "Task \(taskId.rawValue)"
        viewController?.navigationController?.pushViewController(controller, animated: true)
    }
}
