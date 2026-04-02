import Foundation

final class TasksRepositoryImpl: TasksRepository {
    private let client: NetworkClient
    private let decoder: JSONDecoder

    init(client: NetworkClient) {
        self.client = client

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        self.decoder = decoder
    }

    func fetchTasks() async throws -> [TaskModel] {
        try await Task.sleep(nanoseconds: 2_000_000_000)
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/todos") else {
            throw NetworkError.invalidResponse
        }

        let dto: [TaskDTO] = try await client.get(url, decoder: decoder)
        return dto.map(map)
    }

    func getTask(id: TaskID) async throws -> TaskModel? {
        let tasks = try await fetchTasks()
        return tasks.first { $0.id == id }
    }

    func createTask(
        title: String,
        description: String?,
        priority: TaskPriority,
        deadline: Date?
    ) async throws -> TaskModel {
        throw NetworkError.invalidResponse
    }

    func updateTask(_ task: TaskModel) async throws -> TaskModel {
        throw NetworkError.invalidResponse
    }

    func deleteTask(id: TaskID) async throws {
        throw NetworkError.invalidResponse
    }
}

private extension TasksRepositoryImpl {
    func map(_ dto: TaskDTO) -> TaskModel {
        TaskModel(
            id: TaskID(String(dto.id)),
            ownerId: UserID(String(dto.userId)),
            title: dto.title.capitalized,
            description: nil,
            status: mapStatus(dto.completed),
            priority: .medium,
            createdAt: Date(),
            updatedAt: nil,
            deadline: nil
        )
    }

    func mapStatus(_ completed: Bool) -> TaskStatus {
        completed ? .completed : .planned
    }
}
