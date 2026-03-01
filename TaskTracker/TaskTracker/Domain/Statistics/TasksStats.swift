import Foundation

struct TasksStats: Equatable, Codable {
    let total: Int
    let byStatus: [TaskStatus: Int]
    let overdueCount: Int
    let completedCount: Int
}
