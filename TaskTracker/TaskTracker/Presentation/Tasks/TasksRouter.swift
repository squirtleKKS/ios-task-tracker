import Foundation

protocol TasksRouter: AnyObject {
    func openTaskDetails(taskId: TaskID)
}
