import Foundation

protocol TasksService {
    func getTasks(
        filter: TasksFilter,
        sort: TasksSort?
    ) async throws -> [TaskItemVM]

    func getTask(id: TaskID) async throws -> TaskItemVM?

    func createTask(
        title: String,
        description: String?,
        priority: TaskPriority,
        deadline: Date?
    ) async throws -> TaskItemVM

    func updateTask(_ task: TaskModel) async throws -> TaskItemVM

    func deleteTask(id: TaskID) async throws
}
