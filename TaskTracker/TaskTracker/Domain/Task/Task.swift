import Foundation

struct Task: Equatable, Codable {
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
