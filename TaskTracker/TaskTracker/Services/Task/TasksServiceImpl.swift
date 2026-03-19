import Foundation

final class TasksServiceImpl: TasksService {

    private let repository: TasksRepository
    private let now: () -> Date
    private let deadlineFormatter: DateFormatter

    init(
        repository: TasksRepository,
        now: @escaping () -> Date = Date.init
    ) {
        self.repository = repository
        self.now = now

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        self.deadlineFormatter = formatter
    }

    func getTasks(
        filter: TasksFilter,
        sort: TasksSort?
    ) async throws -> [TaskItemVM] {

        let tasks = try await repository.fetchTasks()

        let filtered = applyFilter(tasks, filter: filter)
        let sorted = applySort(filtered, sort: sort)

        return sorted.map(mapToVM)
    }

    func getTask(id: TaskID) async throws -> TaskItemVM? {
        let task = try await repository.getTask(id: id)
        return task.map(mapToVM)
    }

    func createTask(
        title: String,
        description: String?,
        priority: TaskPriority,
        deadline: Date?
    ) async throws -> TaskItemVM {

        let task = try await repository.createTask(
            title: title,
            description: description,
            priority: priority,
            deadline: deadline
        )

        return mapToVM(task)
    }

    func updateTask(_ task: TaskModel) async throws -> TaskItemVM {
        let updated = try await repository.updateTask(task)
        return mapToVM(updated)
    }

    func deleteTask(id: TaskID) async throws {
        try await repository.deleteTask(id: id)
    }
}


private extension TasksServiceImpl {

    func mapToVM(_ task: TaskModel) -> TaskItemVM {
        TaskItemVM(
            id: task.id,
            title: task.title,
            status: task.status,
            priority: task.priority,
            deadlineText: formatDeadline(task.deadline)
        )
    }

    func formatDeadline(_ date: Date?) -> String? {
        guard let date else { return nil }
        return deadlineFormatter.string(from: date)
    }


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

        if task.title.lowercased().contains(query) {
            return true
        }

        if let description = task.description?.lowercased(),
           description.contains(query) {
            return true
        }

        return false
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
                compare($0.deadline ?? .distantFuture, $1.deadline ?? .distantFuture, order: order)
            }

        case .priority(let order):
            return items.sorted {
                compare($0.priority, $1.priority, order: order)
            }

        case .status(let order):
            return items.sorted {
                compare(statusRank($0.status), statusRank($1.status), order: order)
            }
        }
    }

    func compare<T: Comparable>(
        _ lhs: T,
        _ rhs: T,
        order: SortOrder
    ) -> Bool {
        switch order {
        case .ascending:
            return lhs < rhs
        case .descending:
            return lhs > rhs
        }
    }

    func statusRank(_ status: TaskStatus) -> Int {
        switch status {
        case .planned: return 0
        case .inProgress: return 1
        case .completed: return 2
        case .cancelled: return 3
        }
    }
}
