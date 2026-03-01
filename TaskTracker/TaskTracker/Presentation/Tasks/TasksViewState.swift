import Foundation

struct TasksViewState: Equatable {
    var screen: LoadableState<[TaskItemVM]>
    var isRefreshing: Bool
    var filter: TasksFilter
    var sort: TasksSort?
}

struct TaskItemVM: Equatable {
    let id: TaskID
    let title: String
    let status: TaskStatus
    let priority: TaskPriority
    let deadlineText: String?
}
