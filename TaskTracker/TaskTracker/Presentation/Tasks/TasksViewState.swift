import Foundation

struct TasksViewState: Equatable {
    var screen: LoadableState<[TaskItemVM]>
    var isRefreshing: Bool
    var filter: TasksFilter
    var sort: TasksSort?
    var searchQuery: String

    init(
        screen: LoadableState<[TaskItemVM]> = .initial,
        isRefreshing: Bool = false,
        filter: TasksFilter = TasksFilter(),
        sort: TasksSort? = nil,
        searchQuery: String = ""
    ) {
        self.screen = screen
        self.isRefreshing = isRefreshing
        self.filter = filter
        self.sort = sort
        self.searchQuery = searchQuery
    }
}

struct TaskItemVM: Equatable {
    let id: TaskID
    let title: String
    let status: TaskStatus
    let priority: TaskPriority
    let deadlineText: String?
}
