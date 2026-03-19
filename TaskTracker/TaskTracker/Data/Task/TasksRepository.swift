import Foundation

protocol TasksRepository {
    func fetchTasks() async throws -> [TaskModel]
    func getTask(id: TaskID) async throws -> TaskModel?

    func createTask(
        title: String,
        description: String?,
        priority: TaskPriority,
        deadline: Date?
    ) async throws -> TaskModel

    func updateTask(_ task: TaskModel) async throws -> TaskModel

    func deleteTask(id: TaskID) async throws
}
