import Foundation

final class TasksServiceImpl: TasksService {

    private let repository: TasksRepository
    private let now: () -> Date

    init(
        repository: TasksRepository,
        now: @escaping () -> Date = Date.init
    ) {
        self.repository = repository
        self.now = now
    }

    func getTasks(
        filter: TasksFilter,
        sort: TasksSort?
    ) async throws -> [TaskModel] {
        let tasks = try await repository.fetchTasks()
        let filtered = applyFilter(tasks, filter: filter)
        return applySort(filtered, sort: sort)
    }

    func getTask(id: TaskID) async throws -> TaskModel? {
        try await repository.getTask(id: id)
    }

    func createTask(
        title: String,
        description: String?,
        priority: TaskPriority,
        deadline: Date?
    ) async throws -> TaskModel {
        try await repository.createTask(
            title: title,
            description: description,
            priority: priority,
            deadline: deadline
        )
    }

    func updateTask(_ task: TaskModel) async throws -> TaskModel {
        try await repository.updateTask(task)
    }

    func deleteTask(id: TaskID) async throws {
        try await repository.deleteTask(id: id)
    }
}

private extension TasksServiceImpl {

    func applyFilter(
        _ items: [TaskModel],
        filter: TasksFilter
    ) -> [TaskModel] {
        items.filter { task in
            matchesStatuses(task, filter: filter)
            && matchesPriorities(task, filter: filter)
            && matchesOverdue(task, filter: filter)
            && matchesSearch(task, filter: filter)
        }
    }

    func matchesStatuses(_ task: TaskModel, filter: TasksFilter) -> Bool {
        guard !filter.statuses.isEmpty else { return true }
        return filter.statuses.contains(task.status)
    }

    func matchesPriorities(_ task: TaskModel, filter: TasksFilter) -> Bool {
        guard !filter.priorities.isEmpty else { return true }
        return filter.priorities.contains(task.priority)
    }

    func matchesOverdue(_ task: TaskModel, filter: TasksFilter) -> Bool {
        guard filter.overdueOnly else { return true }
        guard let deadline = task.deadline else { return false }

        return deadline < now()
            && task.status != .completed
            && task.status != .cancelled
    }

    func matchesSearch(_ task: TaskModel, filter: TasksFilter) -> Bool {
        guard
            let rawQuery = filter.searchQuery?.trimmingCharacters(in: .whitespacesAndNewlines),
            !rawQuery.isEmpty
        else {
            return true
        }

        let query = rawQuery.lowercased()
        let title = task.title.lowercased()
        let description = task.description?.lowercased() ?? ""

        return title.contains(query) || description.contains(query)
    }

    func applySort(
        _ items: [TaskModel],
        sort: TasksSort?
    ) -> [TaskModel] {
        guard let sort else { return items }

        switch sort {
        case .createdAt(let order):
            return items.sorted {
                compare($0.createdAt, $1.createdAt, order: order)
            }

        case .deadline(let order):
            return items.sorted {
                compareOptionalDates($0.deadline, $1.deadline, order: order)
            }

        case .priority(let order):
            return items.sorted {
                compare($0.priority, $1.priority, order: order)
            }

        case .status(let order):
            return items.sorted {
                compare($0.status.rawValue, $1.status.rawValue, order: order)
            }
        }
    }

    func compare<T: Comparable>(_ lhs: T, _ rhs: T, order: SortOrder) -> Bool {
        switch order {
        case .ascending:
            return lhs < rhs
        case .descending:
            return lhs > rhs
        }
    }

    func compareOptionalDates(_ lhs: Date?, _ rhs: Date?, order: SortOrder) -> Bool {
        switch (lhs, rhs) {
        case let (.some(lhsDate), .some(rhsDate)):
            return compare(lhsDate, rhsDate, order: order)
        case (.some, .none):
            return order == .ascending
        case (.none, .some):
            return order == .descending
        case (.none, .none):
            return false
        }
    }
}
