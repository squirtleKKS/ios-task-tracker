import Foundation

struct TasksFilter: Equatable, Codable {
    let statuses: Set<TaskStatus>
    let priorities: Set<TaskPriority>
    let overdueOnly: Bool
    let searchQuery: String?

    init(
        statuses: Set<TaskStatus> = [],
        priorities: Set<TaskPriority> = [],
        overdueOnly: Bool = false,
        searchQuery: String? = nil
    ) {
        self.statuses = statuses
        self.priorities = priorities
        self.overdueOnly = overdueOnly
        self.searchQuery = searchQuery
    }
}
