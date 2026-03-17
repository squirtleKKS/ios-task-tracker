import Foundation

protocol TasksRepository {
    func fetchTasks(
        filter: TasksFilter,
        sort: TasksSort?
    ) async throws -> [TaskModel]

    func createTask(
        title: String,
        description: String?,
        priority: TaskPriority,
        deadline: Date?
    ) async throws -> TaskModel

    func updateTask(_ task: TaskModel) async throws -> TaskModel

    func deleteTask(id: TaskID) async throws
}
