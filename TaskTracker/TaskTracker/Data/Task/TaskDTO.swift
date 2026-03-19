import Foundation

struct TaskDTO: Codable, Equatable {
    let userId: Int
    let id: Int
    let title: String
    let completed: Bool
}
