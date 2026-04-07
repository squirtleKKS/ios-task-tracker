import Foundation

struct TaskDTO: Decodable, Equatable {
    let userId: Int
    let id: Int
    let title: String
    let completed: Bool
}
