import Foundation

protocol TasksService {
    func getTasks(filter: TasksFilter, sort: TasksSort?) async throws -> [Task]

    func createTask(
        title: String,
        description: String?,
        priority: TaskPriority,
        deadline: Date?
    ) async throws -> Task

    func updateTask(_ task: Task) async throws -> Task

    func deleteTask(id: TaskID) async throws
}
