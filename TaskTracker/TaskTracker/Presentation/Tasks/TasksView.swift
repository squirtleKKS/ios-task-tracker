import Foundation

protocol TasksView: AnyObject {
    func render(_ state: TasksViewState)
}
