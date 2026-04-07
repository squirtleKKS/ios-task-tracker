import Foundation

struct TasksStats: Equatable {
    let total: Int
    let byStatus: [TaskStatus: Int]
    let overdueCount: Int
    let completedCount: Int
}
