import Foundation

struct TaskModel: Equatable {
    let id: TaskID
    let ownerId: UserID

    let title: String
    let description: String?

    let status: TaskStatus
    let priority: TaskPriority

    let createdAt: Date
    let updatedAt: Date?

    let deadline: Date?
}
