import Foundation

@MainActor
protocol TasksViewModel: AnyObject {
    var state: TasksViewState { get }
    var onStateChange: ((TasksViewState) -> Void)? { get set }

    func onAppear()
    func didPullToRefresh()
    func didTapCreate(
        title: String,
        description: String?,
        priority: TaskPriority,
        deadline: Date?
    )
    func didTapDelete(taskId: TaskID)
    func didChangeFilter(_ filter: TasksFilter)
    func didChangeSort(_ sort: TasksSort?)
    func didSelectTask(taskId: TaskID)
}
